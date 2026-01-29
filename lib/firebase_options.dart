// firebase_options.dart — single-platform web config for my-store-app-5db1b

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBGXikJneEzkgPbL7CJIo05gNP8MZD8cE',
    authDomain: 'my-store-app-5db1b.firebaseapp.com',
    projectId: 'my-store-app-5db1b',
    storageBucket: 'my-store-app-5db1b.firebasestorage.app',
    messagingSenderId: '301056269123',
    appId: '1:301056269123:web:431efe8abb24d0c800edf6',
    measurementId: null,
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('DefaultFirebaseOptions are only supported for web in this file.');
  }
}
