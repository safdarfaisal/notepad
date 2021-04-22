import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Screens/notepad.dart';
import 'package:notepad/utilities/document.dart';

class NoteListItem extends StatelessWidget {
  //static int number = 0;
  final User user;
  //final DocumentSnapshot documentSnapshot;
  final Document document;

  // NoteListItem({this.documentSnapshot, this.user});
  NoteListItem({this.document, this.user});

  bool shouldDisplay() {
    if (user.email == document.userEmail || document.userEmail == null) {
      if (document.isDeleted) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
    // return ((user.email == document.userEmail || document.userEmail == null) &&
    //     !document.isDeleted);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
      ),
      // onPressed: () {
      //   if (user.email == documentSnapshot.data()['user'] ||
      //       documentSnapshot.data()['user'] == null) {
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => Notepad(
      //                   updateCurrent: true,
      //                   user: user,
      //                   documentSnapshot: documentSnapshot,
      //                 )));
      //   }
      // },
      onPressed: () {
        if (user.email == document.userEmail || document.userEmail == null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Notepad(
                        updateCurrent: true,
                        user: user,
                        document: document,
                      )));
        }
      },
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.body == null ? 'Not available' : document.body,
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
