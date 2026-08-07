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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCa-_BQdsGBvTb3FsD3UKczQ3GYr59_p6w',
    appId: '1:268842721486:web:b5cedf355dd81d003df09f',
    messagingSenderId: '268842721486',
    projectId: 'gabe-mobile-auto',
    authDomain: 'gabe-mobile-auto.firebaseapp.com',
    storageBucket: 'gabe-mobile-auto.firebasestorage.app',
    measurementId: 'G-N19BECL55W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfH9KR6iNhiCMHJuwr14ptv0NcOk8UFJY',
    appId: '1:268842721486:android:3eb444b9a7c291863df09f',
    messagingSenderId: '268842721486',
    projectId: 'gabe-mobile-auto',
    storageBucket: 'gabe-mobile-auto.firebasestorage.app',
  );
}
