import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? startupError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    // A missing local Firebase API key or platform setup should show a clear
    // configuration screen rather than a blank screen or uncaught exception.
    startupError = error;
  }

  runApp(StanDiagApp(startupError: startupError));
}
