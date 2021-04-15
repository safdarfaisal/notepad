import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Screens/notepad.dart';

class NoteListItem extends StatelessWidget {
  static int number = 0;
  final User user;
  final DocumentSnapshot documentSnapshot;

  NoteListItem({this.documentSnapshot, this.user});
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (user.email == documentSnapshot.data()['user']) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Notepad(updateCurrent: true, user: user),
              ));
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(border: Border.all(color: Colors.white)),
        child: Column(
          children: [
            Text(
              documentSnapshot.data()['textBody'],
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              documentSnapshot.data()['user'],
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
