import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'profile_screen_state.dart';

/// Một bong bóng trang trí trong banner. Vị trí ngang theo fraction (0..1),
/// dịch chuyển tại widget dựa trên [duration]/[delay] tính bằng giây.
class ProfileBubble {
  const ProfileBubble({
    required this.x,
    required this.size,
    required this.duration,
    required this.delay,
    required this.alpha,
  });

  final double x;
  final double size;
  final double duration;
  final double delay;
  final double alpha;
}

class ProfileScreenCubit extends Cubit<ProfileScreenState> {
  ProfileScreenCubit() : super(const ProfileScreenState());

  /// Config bong bóng banner: logic tại đây, widget chỉ render theo thời gian.
  List<ProfileBubble> get bubbles => const [
    ProfileBubble(x: 0.12, size: 34, duration: 2, delay: 0, alpha: 0.22),
    ProfileBubble(x: 0.28, size: 18, duration: 3, delay: 1.2, alpha: 0.3),
    ProfileBubble(x: 0.45, size: 48, duration: 3, delay: 1.9, alpha: 0.16),
    ProfileBubble(x: 0.62, size: 22, duration: 4, delay: 2.8, alpha: 0.26),
    ProfileBubble(x: 0.78, size: 40, duration: 3.5, delay: 0.8, alpha: 0.18),
    ProfileBubble(x: 0.9, size: 26, duration: 1, delay: 3.4, alpha: 0.24),
  ];

  Future<void> logout() async {
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        message: null,
      ),
    );
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      emit(
        state.copyWith(
          status: BlocStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}
