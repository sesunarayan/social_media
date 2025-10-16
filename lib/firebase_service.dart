import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';


class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();


  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;
  late FirebaseMessaging messaging;


  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
    messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();
  }
}