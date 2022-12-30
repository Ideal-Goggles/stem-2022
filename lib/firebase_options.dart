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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDf3aUKlZGyqw_-uB4QQ52ZSbnCUNTSh0U',
    appId: '1:841360814435:android:9e47ff69ead87402c52356',
    messagingSenderId: '841360814435',
    projectId: 'stem-2022',
    storageBucket: 'stem-2022.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1KaB5BLwHWY09CZTVXT8sW9oJF2afXiM',
    appId: '1:841360814435:ios:69280a5916bd9fc1c52356',
    messagingSenderId: '841360814435',
    projectId: 'stem-2022',
    storageBucket: 'stem-2022.appspot.com',
    androidClientId: '841360814435-2tmd55ebujcqbc1f39vdlk6ebvr9n38g.apps.googleusercontent.com',
    iosClientId: '841360814435-i62i73p82knnld63bkh3qb9rrlutcui5.apps.googleusercontent.com',
    iosBundleId: 'com.idealduo.stem2022',
  );
}
