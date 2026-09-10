import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthlife/src/shared/models/user_model.dart';

class UserRepository {
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    return UserModel.fromFirebaseAndFirestore(firebaseUser, doc.data());
  }
}
