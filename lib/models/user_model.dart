import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
