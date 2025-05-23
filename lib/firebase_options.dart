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
    apiKey: 'AIzaSyAHjRu9axzq1djYoYWgd9Q6QoadzevdXEU',
    appId: '1:624285376816:web:07d754ca444233781b68f5',
    messagingSenderId: '624285376816',
    projectId: 'ujilevel-xipplg2',
    authDomain: 'ujilevel-xipplg2.firebaseapp.com',
    storageBucket: 'ujilevel-xipplg2.firebasestorage.app',
    measurementId: 'G-L6F174NNXJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCG9R_dBYXqCYpcjGzbYTYuPW2_O5-skuc',
    appId: '1:624285376816:android:f4a1345736218a821b68f5',
    messagingSenderId: '624285376816',
    projectId: 'ujilevel-xipplg2',
    storageBucket: 'ujilevel-xipplg2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVnyhpZuzEbF9bBj0Iuf6rgP37ZgOeE-Q',
    appId: '1:624285376816:ios:7ffcd8aa9943b4561b68f5',
    messagingSenderId: '624285376816',
    projectId: 'ujilevel-xipplg2',
    storageBucket: 'ujilevel-xipplg2.firebasestorage.app',
    iosClientId:
        '624285376816-ie79d55donmk5tumgmkjilurml7eqgk6.apps.googleusercontent.com',
    iosBundleId: 'com.example.siKasir',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBVnyhpZuzEbF9bBj0Iuf6rgP37ZgOeE-Q',
    appId: '1:624285376816:ios:7ffcd8aa9943b4561b68f5',
    messagingSenderId: '624285376816',
    projectId: 'ujilevel-xipplg2',
    storageBucket: 'ujilevel-xipplg2.firebasestorage.app',
    iosClientId:
        '624285376816-ie79d55donmk5tumgmkjilurml7eqgk6.apps.googleusercontent.com',
    iosBundleId: 'com.example.siKasir',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAHjRu9axzq1djYoYWgd9Q6QoadzevdXEU',
    appId: '1:624285376816:web:3d4bdb6ed265e0081b68f5',
    messagingSenderId: '624285376816',
    projectId: 'ujilevel-xipplg2',
    authDomain: 'ujilevel-xipplg2.firebaseapp.com',
    storageBucket: 'ujilevel-xipplg2.firebasestorage.app',
    measurementId: 'G-YYXQKMFXKC',
  );
}
