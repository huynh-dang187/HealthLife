import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? photoURL;
  final DateTime? dateOfBirth;
  final double? height;
  final double? weight;
  final String? gender;

  UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.gender,
  });

  factory UserModel.fromFirebaseAndFirestore(
    User firebaseUser,
    Map<String, dynamic>? firestoreData,
  ) {
    return UserModel(
      uid: firebaseUser.uid,
      displayName: firestoreData?['displayName'] ?? firebaseUser.displayName,
      email: firestoreData?['email'] ?? firebaseUser.email,
      phoneNumber: firestoreData?['phoneNumber'] ?? firebaseUser.phoneNumber,
      photoURL: firestoreData?['photoURL'] ?? firebaseUser.photoURL,
      dateOfBirth: firestoreData?['dateOfBirth'] != null
          ? (firestoreData!['dateOfBirth']).toDate()
          : null,
      height: firestoreData?['height']?.toDouble(),
      weight: firestoreData?['weight']?.toDouble(),
      gender: firestoreData?['gender'],
    );
  }
}
