import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Screens/notepad.dart';

class NoteListItem extends StatelessWidget {
  static int number = 0;
  final User user;
  final DocumentSnapshot documentSnapshot;

  NoteListItem({this.documentSnapshot, this.user});

  bool shouldDisplay() {
    if (user.email == documentSnapshot.data()['user'] ||
        documentSnapshot.data()['user'] == null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
      ),
      onPressed: () {
        if (user.email == documentSnapshot.data()['user'] ||
            documentSnapshot.data()['user'] == null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Notepad(
                        updateCurrent: true,
                        user: user,
                        documentSnapshot: documentSnapshot,
                      )));
        }
      },
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              documentSnapshot.data()['textBody'] == null
                  ? 'Not available'
                  : documentSnapshot.data()['textBody'],
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
