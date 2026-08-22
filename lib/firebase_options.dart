import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase configuration options loaded securely from environment variables (.env).
class DefaultFirebaseOptions {
  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY'] ?? const String.fromEnvironment('FIREBASE_API_KEY'),
    appId: dotenv.env['FIREBASE_APP_ID'] ?? const String.fromEnvironment('FIREBASE_APP_ID'),
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? const String.fromEnvironment('FIREBASE_MEASUREMENT_ID'),
  );

  static FirebaseOptions get currentPlatform => web;
}
