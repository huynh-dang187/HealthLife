import { onCall } from 'firebase-functions/v2/https';
import { HttpsError } from 'firebase-functions/v2/https';
import { getAuth } from 'firebase-admin/auth';
import { db } from '../config/firebase.js';

/**
 * Kiểm tra SĐT đã được đăng ký trong Firebase Auth chưa.
 * Public (không yêu cầu đăng nhập) vì gọi trước khi xác thực OTP.
 * Trả về: { registered, profileCompleted } (profileCompleted là trạng thái
 * của user doc trong Firestore, để phân biệt đăng nhập lại với tài khoản
 * chưa hoàn tất profile).
 */
export const checkPhoneRegistered = onCall(
  { timeoutSeconds: 15, memory: '256MiB' },
  async (request) => {
    const phone = String(request.data?.phone ?? '').trim();
    if (!phone) {
      throw new HttpsError('invalid-argument', 'Thiếu số điện thoại.');
    }

    let existing;
    try {
      existing = await getAuth().getUserByPhoneNumber(phone);
    } catch (err) {
      const code = String(err?.code ?? '');
      if (code.includes('user-not-found')) {
        return { registered: false };
      }
      throw new HttpsError('internal', 'Không kiểm tra được số điện thoại.');
    }

    let profileCompleted = false;
    try {
      const doc = await db.collection('users').doc(existing.uid).get();
      profileCompleted = doc.data()?.profileCompleted === true;
    } catch (_) {
      // thiếu doc -> coi như chưa hoàn tất profile
    }

    return {
      registered: true,
      uid: existing.uid,
      profileCompleted,
    };
  }
);