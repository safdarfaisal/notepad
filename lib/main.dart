import 'package:flutter/material.dart';
import 'package:notepad/Screens/home_screen.dart';
import 'package:notepad/Screens/login_screen.dart';
import 'package:notepad/Screens/note_list.dart';
import 'package:notepad/Screens/notepad.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
          color: Colors.amber,
        ),
      ),
      home: HomeScreen(),
    );
  }
}
