import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/models/user_model.dart';

class UserCubit extends Cubit<UserModel?> {
  UserCubit() : super(null);

  Future<void> loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      emit(null);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    emit(UserModel.fromFirebaseAndFirestore(firebaseUser, doc.data()));
  }

  void clearUser() => emit(null);
}
