// Copy this file to `lib/firebase_options.dart` after running the
// `flutterfire configure` command or by filling the values below from
// your Firebase project settings.

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  // Replace the placeholder values with your Firebase project's config.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_API_KEY',
    authDomain: 'REPLACE_WITH_AUTH_DOMAIN',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    appId: 'REPLACE_WITH_APP_ID',
  );
}

// Note: The `flutterfire` CLI will generate a complete `firebase_options.dart`
// including platform-specific options. Prefer running `flutterfire configure`.
