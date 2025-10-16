import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;
  final String currentUserId;
  final String currentUserName;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<CommentBottomSheet> createState() => CommentBottomSheetState();
}

class CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  void addComment() async {
    final commentText = _controller.text.trim();
    if (commentText.isEmpty) return;

    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments');

    await commentsRef.add({
      'userId': widget.currentUserId,
      'userName': widget.currentUserName,
      'comment': commentText,
      'timestamp': Timestamp.now(),
    });

    // Increment comment count on post
    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId);
    await postRef.update({'commentCount': FieldValue.increment(1)});

    _controller.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6, // 60% height
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final comments = snapshot.data!.docs;
                  if (comments.isEmpty) {
                    return const Center(child: Text('No comments yet'));
                  }
                  return ListView.builder(
                    reverse: true, // show newest at bottom
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final commentData =
                          comments[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(commentData['comment']),
                        subtitle: Text(commentData['userName']),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
