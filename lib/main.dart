import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notepad/Screens/login_screen.dart';
import 'package:notepad/Screens/note_list.dart';
import 'package:notepad/Screens/notepad.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget userSignedIn() {
    if (FirebaseAuth.instance.currentUser != null) {
      return NoteList(
        user: FirebaseAuth.instance.currentUser,
      );
    } else {
      return HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData().copyWith(
        appBarTheme: AppBarTheme(
          color: Colors.amber,
        ),
      ),
      home: userSignedIn(),
    );
  }
}
