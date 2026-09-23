import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../config/firebase.js';

const MAX_VALID_STEPS = 200000;
const DEFAULT_GOAL = 6000;

/**
 * Khi client ghi bản ghi `users/{userId}/daily_steps/{date}` (bước chân),
 * server sẽ xác thực lại và tự sửa `goalReached` theo `stepGoal` thật của user.
 *
 * Lý do dùng Functions: không tin dữ liệu từ client —
 * `steps`/`goalReached` mà app tự tính có thể bị sửa (hack) qua Firestore rules.
 */
export const validateDailyStepRecord = onDocumentWritten(
  {
    document: 'users/{userId}/daily_steps/{date}',
    region: 'asia-southeast1',
    timeoutSeconds: 60,
  },
  async (event) => {
    const userId = event.params.userId;

    const after = event.data.after;
    if (!after.exists) return; // Bản ghi bị xoá → không can thiệp.

    const data = after.data();
    if (!data || typeof data.steps !== 'number') return;

    // Chặn giá trị vô lý (âm, quá lớn, số thập phân).
    const steps = Math.max(0, Math.min(Math.floor(data.steps), MAX_VALID_STEPS));

    // Mục tiêu thật: ưu tiên stepGoal đã lưu, nếu chưa có dùng mặc định.
    let goal = DEFAULT_GOAL;
    try {
      const userSnap = await db.collection('users').doc(userId).get();
      const stored = userSnap.data()?.stepGoal;
      if (typeof stored === 'number' && stored > 0) goal = stored;
    } catch (err) {
      console.error('[daily_step] lỗi đọc stepGoal:', err);
    }

    const goalReached = steps >= goal;

    // Không thay đổi gì nếu bản ghi đã đúng → tránh vòng lặp trigger.
    if (data.steps === steps && data.goalReached === goalReached) {
      console.log(
        `[daily_step] bản ghi ${userId}/${event.params.date} hợp lệ, bỏ qua.`,
      );
      return;
    }

    await after.ref.update({
      steps,
      goalReached,
      validatedAt: FieldValue.serverTimestamp(),
    });
    console.log(
      `[daily_step] đã chỉnh lại ${userId}/${event.params.date}: steps=$steps goalReached=$goalReached (goal=$goal)`,
    );
  }
);