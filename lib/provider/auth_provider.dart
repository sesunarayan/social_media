import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/views/screens/feed_screen.dart';

import '../firebase_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _auth.currentUser;

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FeedScreen()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      showError(context, e.message ?? 'Login failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
    required BuildContext context
  }) async {
    final firebase = FirebaseService();

    try {
      UserCredential cred = await firebase.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) throw Exception('Signup failed');

      final newUser = UserModel(
        uid: user.uid,
        displayName: name,
        email: user.email ?? '',
        photoUrl: '',
        createdAt: DateTime.now(),
      );

      await firebase.firestore.collection('users').doc(user.uid).set(newUser.toMap());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FeedScreen()),
            (route) => false,
      );
      print('User saved to Firestore successfully!');
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
