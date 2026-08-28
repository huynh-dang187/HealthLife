import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

    // Bước 1: mở popup chọn tài khoản Google (thay cho signIn() cũ)
    final googleUser = await _googleSignIn.authenticate();

    // Bước 2: lấy token xác thực (giờ là thuộc tính đồng bộ, không cần await)
    final googleAuth = googleUser.authentication;

    // Bước 3: đổi thành credential Firebase hiểu được
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Bước 4: đăng nhập vào Firebase
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }
}
