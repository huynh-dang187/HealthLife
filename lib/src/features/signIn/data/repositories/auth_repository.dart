import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Kết quả của luồng verifyPhoneNumber.
sealed class OtpChannel {}

/// Cần nhập mã OTP từ SMS.
final class OtpCodeSent extends OtpChannel {
  final String verificationId;
  final int? resendToken;
  OtpCodeSent(this.verificationId, this.resendToken);
}

/// Android tự xác thực OTP (không cần nhập mã).
final class OtpAutoVerified extends OtpChannel {
  final User user;
  OtpAutoVerified(this.user);
}

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await _googleSignIn.initialize();
    _isInitialized = true;
  }

  Future<User?> signInWithGoogle() async {
    await _ensureInitialized();

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }

  /// Gửi OTP về SĐT (dạng E.164: +84912345678).
  Future<OtpChannel> sendOtp({required String phoneNumber}) async {
    final completer = Completer<OtpChannel>();
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        try {
          final user = await _firebaseAuth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(OtpAutoVerified(user.user!));
          }
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
        }
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (verificationId, forceResendingToken) {
        if (!completer.isCompleted) {
          completer.complete(OtpCodeSent(verificationId, forceResendingToken));
        }
      },
      codeAutoRetrievalTimeout: (_) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('timeout'));
        }
      },
    );
    return completer.future;
  }

  /// Xác thực mã OTP -> đăng nhập Firebase.
  Future<User?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }

  /// Gửi lại OTP với forceResendingToken (không reset quota).
  Future<OtpChannel> resendOtp({
    required String phoneNumber,
    required int resendToken,
  }) async {
    final completer = Completer<OtpChannel>();
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
      verificationCompleted: (credential) async {
        try {
          final user = await _firebaseAuth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(OtpAutoVerified(user.user!));
          }
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
        }
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (verificationId, forceResendingToken) {
        if (!completer.isCompleted) {
          completer.complete(OtpCodeSent(verificationId, forceResendingToken));
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  /// Kiểm tra hồ sơ đã hoàn thiện chưa (khớp logic SplashScreen).
  Future<bool> isProfileCompleted(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data()?['profileCompleted'] ?? false;
  }

  /// Map lỗi FirebaseAuth -> thông báo tiếng Việt.
  String mapAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'Số điện thoại không hợp lệ';
        case 'invalid-verification-code':
          return 'Mã xác nhận sai hoặc đã hết hạn';
        case 'quota-exceeded':
          return 'Đã vượt giới hạn gửi mã, vui lòng thử lại sau';
        case 'too-many-requests':
          return 'Quá nhiều yêu cầu, vui lòng thử lại sau';
        case 'sms-error':
          return 'Không gửi được SMS, vui lòng thử lại';
        case 'network-request-failed':
          return 'Mất kết nối mạng, vui lòng thử lại';
        default:
          return error.message ?? 'Đã có lỗi xảy ra, vui lòng thử lại';
      }
    }
    return error.toString();
  }
}
