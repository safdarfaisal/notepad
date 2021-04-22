import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  int key = 0;
  String userEmail;
  String body;
  int timestamp;
  bool isDeleted;

  Document(
      {this.key, this.userEmail, this.body, this.timestamp, this.isDeleted});

  Map<String, dynamic> toMap() {
    return {
      'id': key,
      'userEmail': userEmail,
      'body': body,
      'timestamp': timestamp,
      'deleted': isDeleted,
    };
  }
}
