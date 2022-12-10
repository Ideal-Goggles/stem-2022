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
    apiKey: 'AIzaSyDbhLQhpM33TN85nU-OwMmyYmcGpFZ0rSc',
    appId: '1:841360814435:web:c7526ad599f92e4dc52356',
    messagingSenderId: '841360814435',
    projectId: 'stem-2022',
    authDomain: 'stem-2022.firebaseapp.com',
    storageBucket: 'stem-2022.appspot.com',
    measurementId: 'G-WDWQEWFBG1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDf3aUKlZGyqw_-uB4QQ52ZSbnCUNTSh0U',
    appId: '1:841360814435:android:6780283cead04e3bc52356',
    messagingSenderId: '841360814435',
    projectId: 'stem-2022',
    storageBucket: 'stem-2022.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1KaB5BLwHWY09CZTVXT8sW9oJF2afXiM',
    appId: '1:841360814435:ios:2d288b680155bc56c52356',
    messagingSenderId: '841360814435',
    projectId: 'stem-2022',
    storageBucket: 'stem-2022.appspot.com',
    iosClientId: '841360814435-j7qrrtm56qga659ib8jpsrf6pjltr21t.apps.googleusercontent.com',
    iosBundleId: 'com.ideal-duo.stem2022',
  );
}
