import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final List<String> mediaUrls;
  final List<String> mediaTypes;
  final DateTime createdAt;
  final Map<String, bool> likes;
  final int commentCount;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.mediaUrls,
    required this.mediaTypes,
    required this.createdAt,
    required this.likes,
    required this.commentCount,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      text: data['text'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      mediaTypes: List<String>.from(data['mediaTypes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: Map<String, bool>.from(data['likes'] ?? {}),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'authorId': authorId,
    'authorName': authorName,
    'text': text,
    'mediaUrls': mediaUrls,
    'mediaTypes': mediaTypes,
    'createdAt': Timestamp.fromDate(createdAt),
    'likes': likes,
    'commentCount': commentCount,
  };
}
