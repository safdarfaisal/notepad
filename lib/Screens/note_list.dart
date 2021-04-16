import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:notepad/Components/note_list_item.dart';
import 'package:notepad/Screens/notepad.dart';

class NoteList extends StatefulWidget {
  static final String id = 'note_list';
  final User user;
  final DocumentSnapshot docSnap;
  NoteList({this.user, this.docSnap});
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  List<DocumentSnapshot> documentList = [];
  bool isMaking = false;
  Future<dynamic> documentSnaphot;

  FirebaseFirestore _firestore;
  CollectionReference notes;

  List<NoteListItem> notesList = [];

  makeListItems() async {
    documentList.clear();
    return notes.get().then((qSnap) => qSnap.docs.forEach((docSnap) {
          documentList.add(docSnap);
        }));
  }

  Future makeNoteComplete() async {
    return await notes
        .get()
        .then((qSnap) => qSnap.docs.forEach((docSnap) {
              documentList.add(docSnap);
              setState(() {});
            }))
        .then((value) => {makeNoteList()});
  }

  Future<void> makeNoteList() async {
    isMaking = true;
    List<NoteListItem> tempList = [];
    notesList.clear();
    for (var docSnap in documentList) {
      NoteListItem newItem = NoteListItem(
        documentSnapshot: docSnap,
        user: widget.user,
      );
      tempList.add(newItem);
    }
    setState(() {
      notesList = tempList;
    });
    isMaking = false;
  }

  waitForData() {
    documentSnaphot = makeNoteComplete();
    setState(() {});
  }

  @override
  void initState() {
    _firestore = FirebaseFirestore.instance;
    notes = _firestore.collection('notes');
    waitForData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: documentSnaphot,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                        ));
                  },
                )
              ],
            ),
            body: ModalProgressHUD(
              inAsyncCall: isMaking,
              child: ListView(
                children: notesList,
              ),
            ),
          );
        });
  }
}
