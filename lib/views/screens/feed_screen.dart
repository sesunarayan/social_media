import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/provider/feed_provider.dart';
import 'package:social_media/views/screens/create_post_screen.dart';
import '../widgets/post_card.dart';
import 'login_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen> {
  late FeedProvider feedProvider;
  String currentUserId = '';
  String userName = '';

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    currentUserId = currentUser?.uid ?? '';
    getCurrentUserDisplayName();
    feedProvider = Provider.of<FeedProvider>(context, listen: false);
    feedProvider.bindStream();
  }

  Future<String> getCurrentUserDisplayName() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return ''; // not logged in

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!doc.exists) return ''; // user document missing

    final data = doc.data()!;
    userName = data['displayName'] ?? '';
    return data['displayName'] ?? '';
  }

  Future<void> confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed'),
        actions: [
          IconButton(
            icon:  Icon(Icons.logout,
            ),
            onPressed: () => confirmLogout(context),
          ),
        ],
      ),
      body: Consumer<FeedProvider>(
        builder: (_, feed, __) {
          if (feed.posts.isEmpty) {
            return const Center(child: Text('No posts yet'));
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                feed.fetchMore();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: feed.posts.length + (feed.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= feed.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final post = feed.posts[index];
                return PostCard(post: post, userId: currentUserId, userName: userName,);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
