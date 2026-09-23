import { onCall } from 'firebase-functions/v2/https';
import { HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { FieldValue } from 'firebase-admin/firestore';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { db } from '../config/firebase.js';

const geminiApiKey = defineSecret('GEMINI_API_KEY');

const MODEL = 'gemini-3.6-flash';
const DAILY_QUOTA = 50;

const SYSTEM_PROMPT = `Bạn là BiBi, trợ lý sức khỏe thông minh của ứng dụng HealthLife, được phát triển bởi BiBi Healthtech.
Nhiệm vụ: trả lời các câu hỏi về sức khỏe, dinh dưỡng, vận động, giấc ngủ, bệnh thường gặp bằng tiếng Việt.
Quy tắc:
- Trả lời ngắn gọn, khoa học, dễ hiểu, không quá 300 từ.
- Nếu câu hỏi vượt kiến thức y khoa, đề nghị tham khảo bác sĩ.
- Không đưa chẩn đoán thay thế bác sĩ.`;

function sessionCol(uid) {
  return db.collection('users').doc(uid).collection('chat_sessions');
}

function messagesCol(uid, sessionId) {
  return sessionCol(uid).doc(sessionId).collection('messages');
}

function getModel(apiKey, temperature = 0.7) {
  const genAI = new GoogleGenerativeAI(apiKey);
  return genAI.getGenerativeModel({
    model: MODEL,
    generationConfig: { temperature },
  });
}

function todayKey() {
  return new Date().toISOString().slice(0, 10);
}

/** Trả về quota hôm nay theo `users/{uid}.chatbotUsage`. */
async function readUsage(uid) {
  const snap = await db.collection('users').doc(uid).get();
  const usage = snap.data()?.chatbotUsage ?? {};
  const today = todayKey();
  if (usage.date !== today) {
    return { date: today, used: 0, quota: DAILY_QUOTA, remaining: DAILY_QUOTA };
  }
  const used = Number(usage.used ?? 0);
  return { date: today, used, quota: DAILY_QUOTA, remaining: DAILY_QUOTA - used };
}

/** Trừ 1 lượt trong ngày. Giữ dữ liệu cũ của user doc bằng merge/field. */
async function consumeUsage(uid) {
  const userRef = db.collection('users').doc(uid);
  const today = todayKey();
  await userRef.set({ chatbotUsage: { date: today } }, { merge: true });
  await userRef.update({
    'chatbotUsage.used': FieldValue.increment(1),
    'chatbotUsage.updatedAt': FieldValue.serverTimestamp(),
  });
}

function serverNow() {
  return FieldValue.serverTimestamp();
}

export const chatbotMessage = onCall(
  { secrets: [geminiApiKey], timeoutSeconds: 60, memory: '512MiB' },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError('unauthenticated', 'Vui lòng đăng nhập để sử dụng BiBi.');
    }

    const message = String(request.data?.message ?? '').trim();
    if (!message) {
      throw new HttpsError('invalid-argument', 'Nội dung tin nhắn không được để trống.');
    }

    const usage = await readUsage(uid);
    if (usage.remaining <= 0) {
      throw new HttpsError(
        'resource-exhausted',
        'Bạn đã hết lượt dùng, vui lòng quay lại sau.'
      );
    }

    const rawSessionId = request.data?.sessionId;
    let sessionId;
    let sessionRef;
    if (typeof rawSessionId === 'string' && rawSessionId.length > 0) {
      sessionId = rawSessionId;
      sessionRef = sessionCol(uid).doc(sessionId);
      const snap = await sessionRef.get();
      if (!snap.exists) {
        throw new HttpsError('not-found', 'Không tìm thấy cuộc trò chuyện.');
      }
    } else {
      sessionRef = sessionCol(uid).doc();
      sessionId = sessionRef.id;
      await sessionRef.set({
        title: 'Cuộc trò chuyện mới',
        pinned: false,
        usageCount: 0,
        createdAt: serverNow(),
        updatedAt: serverNow(),
        lastMessagePreview: message.slice(0, 80),
      });
    }

    await messagesCol(uid, sessionId).add({
      role: 'user',
      content: message,
      createdAt: serverNow(),
    });

    // Lịch sử 10 tin gần nhất làm context.
    const snap = await messagesCol(uid, sessionId)
      .orderBy('createdAt', 'desc')
      .limit(10)
      .get();
    const history = snap.docs
      .reverse()
      .map((doc) => ({
        role: doc.data().role,
        parts: [{ text: doc.data().content }],
      }));
    const chat = getModel(geminiApiKey.value()).startChat({
      history,
      systemInstruction: SYSTEM_PROMPT,
    });
    const result = await chat.sendMessage(message);
    const reply =
      result.response.text()?.trim() ||
      'Xin lỗi, mình chưa hiểu câu hỏi. Bạn thử diễn đạt lại nhé.';

    await messagesCol(uid, sessionId).add({
      role: 'model',
      content: reply,
      createdAt: serverNow(),
    });
    await sessionRef.update({
      updatedAt: serverNow(),
      lastMessagePreview: message.slice(0, 80),
      usageCount: FieldValue.increment(1),
    });

    await consumeUsage(uid);
    const newUsage = await readUsage(uid);

    return { sessionId, reply, usage: newUsage };
  }
);

/** Tự đặt tên phiên dựa trên tin nhắn đầu tiên. Tách riêng khỏi chatbotMessage. */
export const chatbotGenerateTitle = onCall(
  { secrets: [geminiApiKey], timeoutSeconds: 30, memory: '256MiB' },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError('unauthenticated', 'Vui lòng đăng nhập.');
    }

    const message = String(request.data?.message ?? '').trim();
    const sessionId = String(request.data?.sessionId ?? '').trim();
    if (!sessionId || !message) {
      throw new HttpsError('invalid-argument', 'Thiếu sessionId hoặc nội dung.');
    }

    const sessionRef = sessionCol(uid).doc(sessionId);
    const snap = await sessionRef.get();
    if (!snap.exists) {
      throw new HttpsError('not-found', 'Không tìm thấy cuộc trò chuyện.');
    }

    const model = getModel(geminiApiKey.value(), 0.4);
    const result = await model.generateContent(
      `Đặt một tiêu đề ngắn (tối đa 6 từ, tiếng Việt, không dấu chấm câu cuối, không dấu ngoặc) cho cuộc trò chuyện bắt đầu bằng câu hỏi: "${message}". Chỉ trả về tiêu đề.`
    );
    const title = result.response.text()?.trim().slice(0, 60) || 'Cuộc trò chuyện';

    await sessionRef.update({ title });
    return { sessionId, title };
  }
);