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
    apiKey: 'AIzaSyCDPRFVyoNgn4CrjZ0zcqNx6nelWUM6joA',
    appId: '1:482550939255:web:a2ee85d68d367de9e3d072',
    messagingSenderId: '482550939255',
    projectId: 'eco-track-4e198',
    authDomain: 'eco-track-4e198.firebaseapp.com',
    storageBucket: 'eco-track-4e198.firebasestorage.app',
    measurementId: 'G-YESV13N634',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0EMv5ykQxtwO6lpk7FpU0p6Ruqr4IuEg',
    appId: '1:482550939255:android:5ea253b15bffabe4e3d072',
    messagingSenderId: '482550939255',
    projectId: 'eco-track-4e198',
    storageBucket: 'eco-track-4e198.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBnOYobwLRQnUa7TmY81WfldNR_g9ebRY0',
    appId: '1:482550939255:ios:d80fa331337dc506e3d072',
    messagingSenderId: '482550939255',
    projectId: 'eco-track-4e198',
    storageBucket: 'eco-track-4e198.firebasestorage.app',
    iosBundleId: 'com.example.ecoTrack',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBnOYobwLRQnUa7TmY81WfldNR_g9ebRY0',
    appId: '1:482550939255:ios:d80fa331337dc506e3d072',
    messagingSenderId: '482550939255',
    projectId: 'eco-track-4e198',
    storageBucket: 'eco-track-4e198.firebasestorage.app',
    iosBundleId: 'com.example.ecoTrack',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCDPRFVyoNgn4CrjZ0zcqNx6nelWUM6joA',
    appId: '1:482550939255:web:ce7973c9d5813241e3d072',
    messagingSenderId: '482550939255',
    projectId: 'eco-track-4e198',
    authDomain: 'eco-track-4e198.firebaseapp.com',
    storageBucket: 'eco-track-4e198.firebasestorage.app',
    measurementId: 'G-899K83C278',
  );
}
