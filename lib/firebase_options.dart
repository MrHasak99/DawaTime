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
    appId: '1:173965270100:web:b09f542fe0573e4cc8e1c1',
    messagingSenderId: '173965270100',
    projectId: 'medication-cd9b8',
    authDomain: 'medication-cd9b8.firebaseapp.com',
    storageBucket: 'medication-cd9b8.firebasestorage.app',
    measurementId: 'G-J6ZG5HY7G6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqewZt32r_IYN59KCrrP90qYitKDz1wZE',
    appId: '1:173965270100:android:1d70497b7430128cc8e1c1',
    messagingSenderId: '173965270100',
    projectId: 'medication-cd9b8',
    storageBucket: 'medication-cd9b8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABKQR0uOhrIqZ4RXV19C76EEfyzDq9CPQ',
    appId: '1:173965270100:ios:c60bc2b162664226c8e1c1',
    messagingSenderId: '173965270100',
    projectId: 'medication-cd9b8',
    storageBucket: 'medication-cd9b8.firebasestorage.app',
    iosBundleId: 'com.mrhasak99.dawatime',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyABKQR0uOhrIqZ4RXV19C76EEfyzDq9CPQ',
    appId: '1:173965270100:ios:bc0f09e9bf64e849c8e1c1',
    messagingSenderId: '173965270100',
    projectId: 'medication-cd9b8',
    storageBucket: 'medication-cd9b8.firebasestorage.app',
    iosBundleId: 'com.mrhasak99.dawatimeFull',
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
