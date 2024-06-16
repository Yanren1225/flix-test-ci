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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdla_bc7oAXEHSp--pN8T64bJp8wcIh74',
    appId: '1:342559837177:android:3621729c8f4b9c8beecb28',
    messagingSenderId: '342559837177',
    projectId: 'flix-872e',
    storageBucket: 'flix-872e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAzVd6HoALwV1_a9DMmFbwxYUG2V3NvKPM',
    appId: '1:342559837177:ios:6c34d0a054af992beecb28',
    messagingSenderId: '342559837177',
    projectId: 'flix-872e',
    storageBucket: 'flix-872e.appspot.com',
    iosBundleId: 'com.ifreedomer.flix.ShareExtension',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAzVd6HoALwV1_a9DMmFbwxYUG2V3NvKPM',
    appId: '1:342559837177:ios:829944bbca5d6cdbeecb28',
    messagingSenderId: '342559837177',
    projectId: 'flix-872e',
    storageBucket: 'flix-872e.appspot.com',
    iosBundleId: 'com.ifreedomer.flix.mac',
  );
}
