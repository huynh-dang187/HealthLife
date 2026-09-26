import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:http/http.dart' as http;

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

/// Kết quả kiểm tra SĐT đã đăng ký ở server.
final class PhoneCheckResult {
  final bool registered;
  final bool profileCompleted;
  const PhoneCheckResult({
    required this.registered,
    required this.profileCompleted,
  });
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
    final firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      await _saveGoogleUserIfNew(firebaseUser);
    }
    return firebaseUser;
  }

  /// Lưu thông tin Google xuống Firestore khi tài khoản mới chưa có doc.
  /// Chỉ ghi khi doc chưa tồn tại để không đè lên tên người dùng đã chỉnh sửa.
  Future<void> _saveGoogleUserIfNew(User firebaseUser) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid);
    final doc = await ref.get();
    if (doc.exists) {
      debugPrint('[signInWithGoogle] user doc exists, skip creating');
      return;
    }
    debugPrint('[signInWithGoogle] creating user doc ${firebaseUser.uid}');
    await ref.set({
      'displayName': firebaseUser.displayName,
      'email': firebaseUser.email,
      'photoURL': firebaseUser.photoURL,
      'provider': 'google',
      'profileCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
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

  /// Kiểm tra SĐT đã đăng ký trong Firebase Auth chưa (gọi Cloud Function).
  /// Nếu mạng lỗi/function chưa deploy -> fallback "chưa đăng ký" để không
  /// chặn nhầm người dùng mới.
  Future<PhoneCheckResult> checkPhoneRegistered(String fullPhone) async {
    const projectId = String.fromEnvironment(
      'PROJECT_ID',
      defaultValue: 'healthlife-e89fd',
    );
    const region = String.fromEnvironment(
      'REGION',
      defaultValue: 'us-central1',
    );
    final url =
        'https://$region-$projectId.cloudfunctions.net/checkPhoneRegistered';
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'data': {'phone': fullPhone}}),
          )
          .timeout(const Duration(seconds: 20));
      debugPrint(
        '[AuthRepo] checkPhoneRegistered => ${response.statusCode}',
      );
      if (response.statusCode != 200) {
        return const PhoneCheckResult(
          registered: false,
          profileCompleted: false,
        );
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final result = decoded['result'] as Map<String, dynamic>? ?? const {};
      return PhoneCheckResult(
        registered: result['registered'] == true,
        profileCompleted: result['profileCompleted'] == true,
      );
    } catch (e) {
      debugPrint('[AuthRepo] checkPhoneRegistered lỗi: $e');
      return const PhoneCheckResult(
        registered: false,
        profileCompleted: false,
      );
    }
  }

  /// Kiểm tra hồ sơ đã hoàn thiện chưa (khớp logic SplashScreen).
  Future<bool> isProfileCompleted(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data()?['profileCompleted'] ?? false;
  }

  /// Map lỗi FirebaseAuth -> thông báo đã localize.
  String mapAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return LocaleKeys.sign_in_invalid_phone.tr();
        case 'invalid-verification-code':
          return LocaleKeys.sign_in_wrong_code_expired.tr();
        case 'quota-exceeded':
          return LocaleKeys.sign_in_quota_exceeded.tr();
        case 'too-many-requests':
          return LocaleKeys.sign_in_too_many_requests.tr();
        case 'sms-error':
          return LocaleKeys.sign_in_sms_error.tr();
        case 'network-request-failed':
          return LocaleKeys.sign_in_network_error.tr();
        default:
          return error.message ??
              LocaleKeys.sign_in_generic_error.tr();
      }
    }
    return error.toString();
  }
}
