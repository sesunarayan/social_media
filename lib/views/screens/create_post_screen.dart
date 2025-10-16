import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_media/provider/feed_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_service.dart';
import '../../models/post_model.dart';


class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController textController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  final List<File> mediaFiles = [];
  final List<String> mediaTypes = [];
  bool isPosting = false;

  Future<void> _pickMedia({required bool isVideo}) async {
    final XFile? pickedFile = await (isVideo
        ? picker.pickVideo(source: ImageSource.gallery)
        : picker.pickImage(source: ImageSource.gallery, imageQuality: 80));

    if (pickedFile != null) {
      setState(() {
        mediaFiles.add(File(pickedFile.path));
        mediaTypes.add(isVideo ? 'video' : 'image');
      });
    }
  }

  Future<void> createPost() async {
    if (isPosting) return;
    final text = textController.text.trim();
    if (text.isEmpty && mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something or add media')),
      );
      return;
    }

    setState(() => isPosting = true);
    try {
      final FirebaseService firebase = FirebaseService();
      final user = firebase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');
      final userDoc = await firebase.firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.exists ? userDoc['displayName'] ?? 'Anonymous' : 'Anonymous';
      List<String> uploadedUrls = [];

      for (int i = 0; i < mediaFiles.length; i++) {
        final file = mediaFiles[i];
        final type = mediaTypes[i];
        final id = const Uuid().v4();
        final ref = firebase.storage.ref().child('posts/${user.uid}/$id');
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }

      final post = PostModel(
        id: const Uuid().v4(),
        authorId: user.uid,
        authorName: userName,
        text: text,
        mediaUrls: uploadedUrls,
        mediaTypes: mediaTypes,
        createdAt: DateTime.now(),
        commentCount: 0,
        likes: {},
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .set(post.toMap());

      Provider.of<FeedProvider>(context, listen: false).bindStream();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: isPosting ? null : createPost,
            child: isPosting
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                :  Text('Post', style: TextStyle(
                color: Theme.of(context).primaryColor
            )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: textController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'What’s on your mind?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(mediaFiles.length, (i) {
                final file = mediaFiles[i];
                final type = mediaTypes[i];
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: type == 'video'
                          ? const Center(
                        child: Icon(Icons.play_circle, color: Colors.white, size: 40),
                      )
                          : null,
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            mediaFiles.removeAt(i);
                            mediaTypes.removeAt(i);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickMedia(isVideo: false),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Add Image'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickMedia(isVideo: true),
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Add Video'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
