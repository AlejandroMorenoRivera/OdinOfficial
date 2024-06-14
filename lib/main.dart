import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:odin/firebase_options.dart';
import 'package:odin/src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // habilitamos la cache por si no han habido cambios en firebase y necesitamos la info
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  // franja horaria
  // initializeDateFormatting('fr_FR', null).then((_) => runApp(const MainApp()));
  runApp(const MainApp());
}
