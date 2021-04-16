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
        decoration: BoxDecoration(border: Border.all(color: Colors.white)),
        child: Column(
          children: [
            Text(
              documentSnapshot.data()['textBody'] == null
                  ? 'Not available'
                  : documentSnapshot.data()['textBody'],
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
              documentSnapshot.data()['user'] != null
                  ? documentSnapshot.data()['user']
                  : 'Not available',
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
