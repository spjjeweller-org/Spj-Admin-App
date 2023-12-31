// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAbauvOdFJIlUn4dy8p4ISo8g57jccc6kk',
    appId: '1:303738952511:web:d8d585c5c9fea9b85dd18a',
    messagingSenderId: '303738952511',
    projectId: 'scracherspj',
    authDomain: 'scracherspj.firebaseapp.com',
    storageBucket: 'scracherspj.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBO3hx7AFy-c8g8aGYUgZppRtQy6432wLI',
    appId: '1:303738952511:android:fc050420d04fb7b35dd18a',
    messagingSenderId: '303738952511',
    projectId: 'scracherspj',
    storageBucket: 'scracherspj.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZXMTnxJUoeaYwGqeDS3ypoNrX2vL8Wds',
    appId: '1:303738952511:ios:b8efb0f8ca8055a05dd18a',
    messagingSenderId: '303738952511',
    projectId: 'scracherspj',
    storageBucket: 'scracherspj.appspot.com',
    iosClientId: '303738952511-v34e1q09iesbo4v83h4o6hvlkj6bdq5i.apps.googleusercontent.com',
    iosBundleId: 'com.example.spjjwellersadmin',
  );
}
