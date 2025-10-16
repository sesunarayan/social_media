import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../repositories/post_repository.dart';

class FeedProvider with ChangeNotifier {
  final PostRepository _repo;
  List<PostModel> posts = [];
  bool isLoading = false;
  DocumentSnapshot? _lastDoc;
  bool hasMore = true;

  FeedProvider(this._repo);

  void bindStream({int limit = 10}) {
    _repo.streamPosts(limit: limit).listen((snapshotPosts) {
      posts = snapshotPosts;
      notifyListeners();
    });
  }

  Future<void> fetchMore({int limit = 10}) async {
    if (!hasMore || isLoading) return;
    isLoading = true;
    notifyListeners();

    // Implement pagination later if needed

    isLoading = false;
    notifyListeners();
  }

  Future<void> like(String postId, String userId) async {
    await _repo.likePost(postId, userId);
  }
}
