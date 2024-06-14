// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyATbXOkroQTPLWjln6fi4rFm5zuUst_jZA',
    appId: '1:320961108469:web:0737c0473e5ea7243c28bc',
    messagingSenderId: '320961108469',
    projectId: 'odin-87525',
    authDomain: 'odin-87525.firebaseapp.com',
    storageBucket: 'odin-87525.appspot.com',
    measurementId: 'G-WBPC5NFB3C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqizgN3AA9zHqjjY3Op3_gTx5sH2m-yno',
    appId: '1:320961108469:android:71c6290fb8a7d4e73c28bc',
    messagingSenderId: '320961108469',
    projectId: 'odin-87525',
    storageBucket: 'odin-87525.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAFuXoH1JvZAszJw8aYNmKizmVJ38LtRfY',
    appId: '1:320961108469:ios:dfb583ea79b7952f3c28bc',
    messagingSenderId: '320961108469',
    projectId: 'odin-87525',
    storageBucket: 'odin-87525.appspot.com',
    iosBundleId: 'com.example.odin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAFuXoH1JvZAszJw8aYNmKizmVJ38LtRfY',
    appId: '1:320961108469:ios:dfb583ea79b7952f3c28bc',
    messagingSenderId: '320961108469',
    projectId: 'odin-87525',
    storageBucket: 'odin-87525.appspot.com',
    iosBundleId: 'com.example.odin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyATbXOkroQTPLWjln6fi4rFm5zuUst_jZA',
    appId: '1:320961108469:web:9f8edb2c5a2d57e33c28bc',
    messagingSenderId: '320961108469',
    projectId: 'odin-87525',
    authDomain: 'odin-87525.firebaseapp.com',
    storageBucket: 'odin-87525.appspot.com',
    measurementId: 'G-YXHT5XYVD9',
  );

}