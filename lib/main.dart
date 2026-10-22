import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep Firebase initialization as the verified integration boundary.
  // Feature-specific Firebase services will be reintroduced only when their
  // replacement flows are implemented.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StanDiagApp());
}
