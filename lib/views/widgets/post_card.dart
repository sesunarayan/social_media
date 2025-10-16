import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/post_model.dart';
import 'comment_bottom_sheet.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final String userId;
  final String userName;

  const PostCard({
    super.key,
    required this.post,
    required this.userId,
    required this.userName,
  });

  Future<void> toggleLike(String postId, String userId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    final doc = await postRef.get();
    final likes = Map<String, bool>.from(doc['likes'] ?? {});

    if (likes.containsKey(userId)) {
      likes.remove(userId);
    } else {
      likes[userId] = true;
    }

    await postRef.update({'likes': likes});
  }

  Future<void> addComment(String postId, String userId, String comment) async {
    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments');

    await commentsRef.add({
      'userId': userId,
      'comment': comment,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    post.authorName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('${post.createdAt.toLocal()}'.split('.').first),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.text),
            const SizedBox(height: 8),
            if (post.mediaUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.mediaUrls.length,
                  itemBuilder: (context, i) {
                    final url = post.mediaUrls[i];
                    final type = post.mediaTypes[i];
                    if (type == 'image') {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: 8.0),
                        color: Colors.black12,
                        child: const Center(
                          child: Icon(Icons.play_circle_fill, size: 48),
                        ),
                      );
                    }
                  },
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => toggleLike(post.id, userId),
                  child: Row(
                    children: [
                      Icon(
                        post.likes.containsKey(userId)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: post.likes.containsKey(userId)
                            ? Colors.red
                            : Colors.grey,
                      ),
                      SizedBox(width: 7),
                      Text('${post.likes.length} likes'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      // so the keyboard can push the sheet up
                      builder: (context) => CommentBottomSheet(
                        postId: post.id,
                        currentUserId: userId,
                        currentUserName: userName,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.comment),
                      SizedBox(width: 7),
                      Text('${post.commentCount} comments'),
                    ],
                  ),
                ),
                SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
