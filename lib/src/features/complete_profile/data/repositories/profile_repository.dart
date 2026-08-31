import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepository {
  Future<void> saveProfile({
    required String displayName,
    required DateTime dateOfBirth,
    required String gender,
    required double height,
    required double weight,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'displayName': displayName,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'height': height,
      'weight': weight,
      'profileCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateDisplayName(String displayName) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'displayName': displayName,
    }, SetOptions(merge: true));
  }

  Future<void> updateDisplayGender(String displayGender) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'gender': displayGender,
    });
  }

  Future<void> updateDisplayDate(DateTime dateOfBirth) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
    });
  }

  Future<void> updateDisplayHeight(double height) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'height': height,
    });
  }

  Future<void> updateDisplayWeight(double weight) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'weight': weight,
    });
  }
}
