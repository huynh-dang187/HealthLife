import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onCall } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { FieldValue } from 'firebase-admin/firestore';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { db } from '../config/firebase.js';

const geminiApiKey = defineSecret('GEMINI_API_KEY');

function todayKey() {
  return new Date().toISOString().slice(0, 10);
}

async function fetchTipFromGemini(apiKey) {
  // 1. Danh sách các chủ đề cố định
  const categories = [
    'dinh dưỡng',
    'vận động',
    'giấc ngủ',
    'tinh thần',
    'nước',
    'tổng quát',
  ];

  // 2. Chọn ngẫu nhiên 1 chủ đề từ code trước khi gọi Gemini
  const selectedCategory = categories[Math.floor(Math.random() * categories.length)];

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({
    model: 'gemini-3.6-flash',
    generationConfig: {
      responseMimeType: 'application/json',
      temperature: 0.9, // Tăng tính sáng tạo, tránh lặp lại các mẹo quen thuộc
    },
  });

  // 3. Ép Gemini viết lời khuyên đúng cho chủ đề đã bốc thăm
  const prompt = `
Bạn là chuyên gia chăm sóc sức khỏe. Hôm nay hãy đưa ra MỘT lời khuyên sức khỏe ngắn gọn, thiết thực, khoa học và dễ áp dụng bằng tiếng Việt.

Yêu cầu bắt buộc:
- Chủ đề chỉ định hôm nay là: "${selectedCategory}". Lời khuyên PHẢI tập trung vào chủ đề này.
- Tránh những lời khuyên quá sáo rỗng hoặc hiển nhiên.

Định dạng JSON bắt buộc:
{
  "tip": "nội dung lời khuyên hữu ích, dưới 180 ký tự",
  "category": "${selectedCategory}",
  "emoji": "một emoji biểu cảm phù hợp với nội dung lời khuyên"
}
`;

  const result = await model.generateContent(prompt);
  const json = JSON.parse(result.response.text());
  return {
    tip: String(json.tip ?? ''),
    category: String(json.category ?? selectedCategory),
    emoji: String(json.emoji ?? '💚'),
  };
}

export const generateDailyTip = onSchedule(
  { schedule: 'every day 00:05', secrets: [geminiApiKey], timeoutSeconds: 60 },
  async () => {
    const key = todayKey();
    const ref = db.collection('daily_tips').doc(key);
    const snap = await ref.get();
    if (snap.exists) return;

    const tip = await fetchTipFromGemini(geminiApiKey.value());
    await ref.set({ ...tip, createdAt: FieldValue.serverTimestamp() });
  }
);

export const testGenerateTip = onCall(
  { secrets: [geminiApiKey], timeoutSeconds: 60, invoker: 'public' },
  async () => {
    const key = todayKey();
    const ref = db.collection('daily_tips').doc(key);
    const snap = await ref.get();
    if (snap.exists) return { skipped: true, data: snap.data() };

    const tip = await fetchTipFromGemini(geminiApiKey.value());
    await ref.set({ ...tip, createdAt: FieldValue.serverTimestamp() });
    return { skipped: false, data: tip };
  }
);