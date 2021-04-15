import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Screens/note_list.dart';

class Notepad extends StatefulWidget {
  static final String id = 'notepad';
  final bool updateCurrent;
  final String title;
  final User user;
  Notepad({@required this.updateCurrent, @required this.user, this.title});
  @override
  _NotepadState createState() => _NotepadState();
}

class _NotepadState extends State<Notepad> {
  TextEditingController _controller;
  FirebaseFirestore _firestore;
  CollectionReference notes;
  String textBody = '';
  @override
  void initState() {
    _firestore = FirebaseFirestore.instance;
    notes = _firestore.collection('notes');
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notepad'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  if (textBody != null) {
                    notes.add({
                      'textBody': textBody,
                      'user': 'safdar.faisal@gmail.com',
                    }).then((value) => {
                          value.get().then((docRef) => {
                                // print(docRef.data())

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NoteList(
                                              user: widget.user,
                                              docSnap: docRef,
                                            )))
                              }),
                          print(textBody),
                          // notes
                          //     .get()
                          //     .then((qSnap) => qSnap.docs.forEach((docSnap) {
                          //           print(docSnap.data());
                          //         }))
                        });
                    /*
                    .then(notes.get().asStream().forEach((element) {
                      print(element);
                    }));*/

                  }
                }),
          ],
        ),
        body: TextField(
          controller: _controller,
          onChanged: (value) {
            setState(() {
              textBody = value;
            });
          },
        ));
  }
}
