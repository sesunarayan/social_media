import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostRepository {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');

  Future<DocumentReference> createPost(Map<String, dynamic> data) async {
    return await postsRef.add(data);
  }

  Stream<List<PostModel>> streamPosts({int limit = 10, DocumentSnapshot? startAfter}) {
    Query q = postsRef.orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    return q.snapshots().map((snap) => snap.docs.map((d) => PostModel.fromDoc(d)).toList());
  }

  Future<void> likePost(String postId, String userId) async {
    final likeRef = postsRef.doc(postId).collection('likes').doc(userId);
    final postRef = postsRef.doc(postId);

    final likeDoc = await likeRef.get();
    if (likeDoc.exists) {
      await likeRef.delete();
      await postRef.update({'likeCount': FieldValue.increment(-1)});
    } else {
      await likeRef.set({'createdAt': FieldValue.serverTimestamp()});
      await postRef.update({'likeCount': FieldValue.increment(1)});
    }
  }

  Future<bool> isLiked(String postId, String userId) async {
    final likeDoc = await postsRef.doc(postId).collection('likes').doc(userId).get();
    return likeDoc.exists;
  }

}
