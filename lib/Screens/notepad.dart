import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Screens/note_list.dart';

class Notepad extends StatefulWidget {
  static final String id = 'notepad';
  final bool updateCurrent;
  final String title;
  final User user;
  final DocumentSnapshot documentSnapshot;
  Notepad(
      {@required this.updateCurrent,
      @required this.user,
      this.title,
      this.documentSnapshot});
  @override
  _NotepadState createState() => _NotepadState();
}

class _NotepadState extends State<Notepad> {
  TextEditingController _controller;
  FirebaseFirestore _firestore;
  CollectionReference notes;
  CollectionReference documents;
  String textBody = '';

  initializeApp() async {
    await Firebase.initializeApp();
  }

  @override
  void initState() {
    initializeApp();
    print(widget.user);
    _firestore = FirebaseFirestore.instance;
    notes = _firestore.collection('notes');
    documents = _firestore.collection('documents');
    _controller = TextEditingController();

    if (widget.updateCurrent) {
      _controller.text = widget.documentSnapshot.data()['textBody'];
      textBody = _controller.text;
    }
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
                  if (!widget.updateCurrent) {
                    if (textBody != null) {
                      notes.add({
                        'textBody': textBody,
                        'user': widget.user.email,
                      }).then((value) => {
                            value.get().then((docRef) => {
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
                  } else {
                    print(widget.documentSnapshot.reference.id);
                    notes.doc(widget.documentSnapshot.reference.id).set({
                      "textBody": textBody,
                      "user": widget.user.email
                    }).then((docRef) => {
                          print('User'),
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => NoteList(
                                        user: widget.user,
                                      )),
                              (Route<dynamic> route) => false)
                        });
                  }
                }),
            IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () {
                  notes.doc(widget.documentSnapshot.reference.id).delete();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => NoteList(
                                user: widget.user,
                              )),
                      (Route<dynamic> route) => false);
                })
          ],
        ),
        body: SingleChildScrollView(
          child: TextField(
            style: TextStyle(
              color: Colors.black,
            ),
            autofocus: true,
            autocorrect: true,
            decoration: InputDecoration(
              fillColor: Colors.white,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            controller: _controller,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onChanged: (value) {
              setState(() {
                textBody = value;
              });
            },
          ),
        ));
  }
}
