// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyAhDn-8YAZvCnVO-ARF6uuUJO6YkPBbmS8',
    appId: '1:173965270100:web:9004dbac7b9d6632c8e1c1',
    messagingSenderId: '173965270100',
    projectId: 'medication-cd9b8',
    authDomain: 'medication-cd9b8.firebaseapp.com',
    storageBucket: 'medication-cd9b8.firebasestorage.app',
    measurementId: 'G-9WVYDRHCD3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqewZt32r_IYN59KCrrP90qYitKDz1wZE',
    appId: '1:173965270100:android:5d86b1f9277d21c5c8e1c1',
    messagingSenderId: '173965270100',
    projectId: 'medication-cd9b8',
    storageBucket: 'medication-cd9b8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABKQR0uOhrIqZ4RXV19C76EEfyzDq9CPQ',
    appId: '1:173965270100:ios:bc0f09e9bf64e849c8e1c1',
    messagingSenderId: '173965270100',
    projectId: 'medication-cd9b8',
    storageBucket: 'medication-cd9b8.firebasestorage.app',
    iosBundleId: 'com.example.medicationAppFull',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyABKQR0uOhrIqZ4RXV19C76EEfyzDq9CPQ',
    appId: '1:173965270100:ios:bc0f09e9bf64e849c8e1c1',
    messagingSenderId: '173965270100',
    projectId: 'medication-cd9b8',
    storageBucket: 'medication-cd9b8.firebasestorage.app',
    iosBundleId: 'com.example.medicationAppFull',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAhDn-8YAZvCnVO-ARF6uuUJO6YkPBbmS8',
    appId: '1:173965270100:web:7f8b51d524a38e77c8e1c1',
    messagingSenderId: '173965270100',
    projectId: 'medication-cd9b8',
    authDomain: 'medication-cd9b8.firebaseapp.com',
    storageBucket: 'medication-cd9b8.firebasestorage.app',
    measurementId: 'G-DD09JLDGP1',
  );
}
