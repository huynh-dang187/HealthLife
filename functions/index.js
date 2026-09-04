import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onCall } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { GoogleGenerativeAI } from '@google/generative-ai';

// Khởi tạo Admin SDK một lần duy nhất
if (!getApps().length) {
  initializeApp();
}
const db = getFirestore();

const geminiApiKey = defineSecret('GEMINI_API_KEY');

function todayKey() {
  return new Date().toISOString().slice(0, 10); // yyyy-MM-dd theo UTC
}

async function fetchTipFromGemini(apiKey) {
  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({
    model: 'gemini-3.6-flash',
    generationConfig: {
      responseMimeType: 'application/json', // Ép trả về JSON chuẩn, không dính markdown
    },
  });

  const prompt = `
Bạn là trợ lý sức khỏe. Hãy đưa ra MỘT lời khuyên sức khỏe ngắn gọn, hữu ích, bằng tiếng Việt.
Theo đúng định dạng JSON:
{
  "tip": "nội dung lời khuyên, dưới 200 ký tự",
  "category": "một trong: dinh dưỡng, vận động, giấc ngủ, tinh thần, nước, tổng quát",
  "emoji": "một emoji phù hợp"
}
`;

  const result = await model.generateContent(prompt);
  const text = result.response.text();
  const json = JSON.parse(text);

  return {
    tip: String(json.tip ?? ''),
    category: String(json.category ?? 'tổng quát'),
    emoji: String(json.emoji ?? '💚'),
  };
}

export const generateDailyTip = onSchedule(
  { schedule: 'every day 00:05', secrets: [geminiApiKey], timeoutSeconds: 60 },
  async () => {
    const key = todayKey();
    const ref = db.collection('daily_tips').doc(key);
    const snap = await ref.get();
    if (snap.exists) {
      console.log(`Tip đã có cho ${key}, bỏ qua.`);
      return;
    }
    const apiKey = geminiApiKey.value();
    const tip = await fetchTipFromGemini(apiKey);
    await ref.set({ ...tip, createdAt: FieldValue.serverTimestamp() });
    console.log(`Đã tạo tip mới cho ${key}:`, tip.tip);
  }
);

export const testGenerateTip = onCall(
  {
    secrets: [geminiApiKey],
    timeoutSeconds: 60,
    invoker: 'public', // Cho phép curl/test chạy không bị chặn Auth
  },
  async () => {
    const key = todayKey();
    const ref = db.collection('daily_tips').doc(key);
    const snap = await ref.get();
    if (snap.exists) return { skipped: true, data: snap.data() };
    
    const apiKey = geminiApiKey.value();
    const tip = await fetchTipFromGemini(apiKey);
    await ref.set({ ...tip, createdAt: FieldValue.serverTimestamp() });
    return { skipped: false, data: tip };
  }
);