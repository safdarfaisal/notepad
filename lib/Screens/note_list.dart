import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:notepad/Components/note_list_item.dart';
import 'package:notepad/Screens/login_screen.dart';
import 'package:notepad/Screens/notepad.dart';
import 'package:notepad/utilities/document.dart';
import 'package:notepad/utilities/storage.dart';

class NoteList extends StatefulWidget {
  static final String id = 'note_list';
  final User user;
  //final DocumentSnapshot docSnap;
  final Document document;
  NoteList({this.user, this.document});
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  List<Document> documentList = [];
  bool isMaking = false;
  // Future<dynamic> documentSnaphot;
  Future<void> docFuture;

  //FirebaseFirestore _firestore;
  //CollectionReference notes;
  Storage notes;

  List<NoteListItem> notesList = [];

  makeListItems() async {
    documentList.clear();
    return notes.readAll().then((docList) => docList.forEach((doc) {
          documentList.add(doc);
        }));
  }

  Future<void> makeNoteComplete() async {
    print("makeNoteComplete");
    return await notes.readAll().then((docList) {
      print(docList.length);
      docList.forEach((doc) {
        //print("docList" + docList.toString());
        //print(doc.key.toString());
        documentList.add(doc);
      });
    }).then((value) => {makeNoteList()});
  }

  Future<void> makeNoteList() async {
    print("makeNoteList");
    isMaking = true;
    notesList.clear();
    List<NoteListItem> tempList = [];
    tempList.clear();
    for (var doc in documentList) {
      NoteListItem newItem = NoteListItem(
        document: doc,
        user: widget.user,
      );
      if (newItem.shouldDisplay()) {
        tempList.add(newItem);
      }
    }
    notesList = tempList;
    isMaking = false;
  }

  waitforinit() async {
    print("waitForInit");
    notesList.clear();
    notes = await Storage.instance();
    docFuture = makeNoteComplete();
    setState(() {});
  }

  waitForfullSync() {
    notesList.clear();
    notes.syncAllDocuments(widget.user.email).then((value) {
      setState(() {});
    });
  }

  waitfortimestampsync() {
    notes.syncWithTimeStamp(widget.user.email).then((value) {
      setState(() {});
    });
  }

  waitForCleaningDatabase() {
    notes.clearDatabase(widget.user.email).then((value) {
      setState(() {});
    });
  }

  waitForLogOut() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await auth.signOut().then(
      (value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
            (route) => false);
      },
    );
  }

  @override
  void initState() {
    //_firestore = FirebaseFirestore.instance;
    //notes = _firestore.collection('notes');
    waitforinit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: docFuture,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            color: Colors.amber,
          );
        }

        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('List of Notes'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    print(widget.user);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Notepad(
                          updateCurrent: false,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.sync),
                  onPressed: () {
                    waitForfullSync();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    waitfortimestampsync();
                  },
                ),
                IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      waitForLogOut();
                    })
              ],
            ),
            body: ModalProgressHUD(
              inAsyncCall: isMaking,
              child: ListView(
                children: notesList,
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.delete_forever),
              onPressed: () {
                waitForCleaningDatabase();
              },
            ),
          );
        }
      },
    );
  }
}
