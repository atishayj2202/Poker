import 'package:flutter/material.dart';
import 'SignIn.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: 'POKER',
      theme: new ThemeData(
        brightness:Brightness.dark,
        primarySwatch: Colors.green,
        primaryColor: Colors.green,
        accentColor: const Color(0xFF64ffda),
        canvasColor: const Color(0xFF303030),
        fontFamily: 'Merriweather',
      ),
      home: new MySignIn(),
    );
  }
}
