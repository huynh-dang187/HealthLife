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
  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({
    model: 'gemini-3.6-flash',
    generationConfig: { responseMimeType: 'application/json' },
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
  const json = JSON.parse(result.response.text());
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