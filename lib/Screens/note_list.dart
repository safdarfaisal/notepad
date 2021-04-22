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
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
    print(notesList);
    List<NoteListItem> tempList = [];
    tempList.clear();
    for (var doc in documentList) {
      NoteListItem newItem = NoteListItem(
        document: doc,
        user: widget.user,
      );

      if (newItem.shouldDisplay() && !newItem.document.isDeleted) {
        tempList.add(newItem);
      }
    }
    print(tempList);
    setState(() {
      notesList = tempList;
    });
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
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => NoteList(
                    user: widget.user,
                  )),
          (route) => false);
    });
  }

  waitfortimestampsync() {
    notes.syncWithTimeStamp(widget.user.email).then((value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => NoteList(
                    user: widget.user,
                  )),
          (route) => false);
    });
  }

  waitForCleaningDatabase() {
    notes.clearDatabase(widget.user.email).then((value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => NoteList(
                    user: widget.user,
                  )),
          (route) => false);
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
        if (snapshot.hasError) {
          return Container(
            color: Colors.red,
          );
        }

        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('List of Notes'),
            ),
            body: ModalProgressHUD(
              inAsyncCall: isMaking,
              child: ListView(
                children: notesList,
              ),
            ),
            // floatingActionButton: FloatingActionButton(
            //   child: Icon(Icons.add),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => Notepad(
            //           updateCurrent: false,
            //           user: widget.user,
            //         ),
            //       ),
            //     );
            //   },
            // ),
            floatingActionButton: SpeedDial(
              marginEnd: 18,
              marginBottom: 20,
              animatedIcon: AnimatedIcons.arrow_menu,
              buttonSize: 56.0,
              activeBackgroundColor: Colors.amber,
              visible: true,
              renderOverlay: false,
              curve: Curves.bounceIn,
              overlayColor: Colors.black,
              overlayOpacity: 0.5,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 8.0,
              shape: CircleBorder(),
              children: [
                SpeedDialChild(
                    child: Icon(
                      Icons.add,
                    ),
                    backgroundColor: Colors.amber,
                    label: 'Add New Note',
                    labelStyle: TextStyle(fontSize: 18.0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Notepad(
                            updateCurrent: false,
                            user: widget.user,
                          ),
                        ),
                      );
                    }),
                SpeedDialChild(
                  child: Icon(
                    Icons.refresh,
                  ),
                  backgroundColor: Colors.amber,
                  label: 'Basic Refresh',
                  labelStyle: TextStyle(fontSize: 18.0),
                  onTap: () {
                    waitfortimestampsync();
                  },
                ),
                SpeedDialChild(
                  child: Icon(
                    Icons.sync,
                  ),
                  backgroundColor: Colors.amber,
                  label: 'full sync to cloud',
                  labelStyle: TextStyle(fontSize: 18.0),
                  onTap: () => waitForfullSync(),
                ),
                SpeedDialChild(
                  child: Icon(
                    Icons.clear_all,
                  ),
                  backgroundColor: Colors.amber,
                  label: 'Clear all notes',
                  labelStyle: TextStyle(fontSize: 18.0),
                  onTap: () => waitForCleaningDatabase(),
                ),
                SpeedDialChild(
                  child: Icon(
                    Icons.logout,
                  ),
                  backgroundColor: Colors.amber,
                  label: 'Log Out',
                  labelStyle: TextStyle(fontSize: 18.0),
                  onTap: () => waitForLogOut(),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
