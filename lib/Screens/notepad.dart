import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Screens/note_list.dart';
import 'package:notepad/utilities/document.dart';
import 'package:notepad/utilities/storage.dart';

class Notepad extends StatefulWidget {
  static final String id = 'notepad';
  final bool updateCurrent;
  final String title;
  final User user;
  //final DocumentSnapshot documentSnapshot;
  final Document document;

  Notepad(
      {@required this.updateCurrent,
      @required this.user,
      this.title,
      this.document});
  @override
  _NotepadState createState() => _NotepadState();
}

class _NotepadState extends State<Notepad> {
  TextEditingController _controller;
  //FirebaseFirestore _firestore;
  //CollectionReference notes;
  //CollectionReference documents;
  Storage notes;
  String textBody = '';

  initializeApp() async {
    await Firebase.initializeApp();
  }

  waitforinit() async {
    notes = await Storage.instance();
  }

  @override
  void initState() {
    initializeApp();
    print(widget.user);
    //_firestore = FirebaseFirestore.instance;
    //notes = _firestore.collection('notes');
    waitforinit();
    //documents = _firestore.collection('documents');
    _controller = TextEditingController();

    if (widget.updateCurrent) {
      _controller.text = widget.document.body;
      textBody = _controller.text;
    }
    super.initState();
  }

  waitForSync() async {
    await notes.syncWithTimeStamp(widget.user.email);
    setState(() {});
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
                      notes
                          .add(Document(
                              userEmail: widget.user.email, body: textBody))
                          .then((value) => {waitForSync()})
                          .then((id) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NoteList(
                                        user: widget.user,
                                      ))));
                      // notes.add({
                      //   'textBody': textBody,
                      //   'user': widget.user.email,
                      // }).then((value) => {
                      //       value.get().then((docRef) => {}),
                      //       print(textBody),
                      //       // notes
                      //       //     .get()
                      //       //     .then((qSnap) => qSnap.docs.forEach((docSnap) {
                      //       //           print(docSnap.data());
                      //       //         }))
                      //     });
                      /*
                    .then(notes.get().asStream().forEach((element) {
                      print(element);
                    }));*/

                    }
                  } else {
                    print(widget.document.key);
                    // notes.read(widget.document.key).then((list) => null)
                    notes
                        .modify(Document(
                            key: widget.document.key,
                            userEmail: widget.user.email,
                            body: textBody))
                        .then((value) => {waitForSync()})
                        .then(
                            (value) => Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => NoteList(
                                          user: widget.user,
                                        )),
                                (Route<dynamic> route) => false));

                    // set({"textBody": textBody, "user": widget.user.email})
                    //     .then((docRef) => {
                    //           print('User'),
                    //           Navigator.of(context).pushAndRemoveUntil(
                    //               MaterialPageRoute(
                    //                   builder: (context) => NoteList(
                    //                         user: widget.user,
                    //                       )),
                    //               (Route<dynamic> route) => false)
                    //         });
                  }
                }),
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () {
                if (widget.updateCurrent) {
                  notes.del(widget.document.key);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => NoteList(
                                user: widget.user,
                              )),
                      (Route<dynamic> route) => false);
                }
              },
            ),
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
