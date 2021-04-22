import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'document.dart';

class Storage {
  List<DocumentSnapshot> documentList = [];
  Future<dynamic> documentSnaphot;

  FirebaseFirestore _firestore;
  CollectionReference notes;

  static bool _inited = false;
  static Storage _instance;

  static Future<Storage> instance() async {
    print("instance");
    print("inited " + _inited.toString());
    if (!_inited) {
      _instance = Storage();
      await _instance.init();
      print("inited " + _inited.toString());
    }
    print("inited " + _inited.toString());
    return _instance;
  }

  init() async {
    _firestore = FirebaseFirestore.instance;
    //db = await openDatabase();

    Database db = await openDatabase(
      'np.db',
      version: 1,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
            'CREATE TABLE NOTES (id INTEGER PRIMARY KEY AUTOINCREMENT, useremail TEXT, body TEXT, timestamp INTEGER, deleted INTEGER DEFAULT 0 CHECK (deleted = 0 OR deleted = 1))');
      },
    );

    await db.close();

    _inited = true;
  }

  destroy() {
    _inited = false;
  }

  Future<int> add(Document doc) async {
    if (_inited) {
      return await openDatabase('np.db').then(
        (db) async {
          int id = await db.insert("NOTES", {
            'useremail': doc.userEmail,
            'body': doc.body,
            "timestamp": DateTime.now().microsecondsSinceEpoch,
          });

          // int id = await db.transaction(
          //   (txn) async {
          //     return txn.rawInsert(
          //         'INSERT INTO NOTES(useremail, body) VALUES (${doc.userEmail}, ${doc.body}');
          //   },
          // );
          await db.close();
          return id;
        },
      );
    }
    return Future.error("Database not available");
  }

  del(int id) async {
    if (_inited) {
      return await openDatabase('np.db').then((db) async {
        // await db.rawDelete('DELETE FROM NOTES WHERE id = ?', [id]);
        await db.rawUpdate(
            'UPDATE NOTES SET deleted = ?, timestamp = ? WHERE id = ?',
            [1, DateTime.now().microsecondsSinceEpoch, id]);
        await db.close();
      });
    }
    return Future.error("Database not available");
  }

  Future<int> modify(Document doc) async {
    if (_inited) {
      return await openDatabase('np.db').then((db) async {
        int i = await db.rawUpdate(
            'UPDATE NOTES SET useremail = ?, body = ?, timestamp = ? WHERE id = ?',
            [
              doc.userEmail,
              doc.body,
              DateTime.now().microsecondsSinceEpoch,
              doc.key,
            ]);
        await db.close();
        return i;
      });
    }
    return Future.error("Database not available");
  }

  Future<List<Document>> read(int id) async {
    if (_inited) {
      return await openDatabase('np.db').then((db) async {
        List<Document> ls;
        await db.rawQuery('SELECT * FROM NOTES WHERE id = ? AND deleted = 0',
            [id]).then((rs) {
          rs.forEach((rec) {
            bool deleted;
            if (rec['deleted'] == 1) {
              deleted = true;
            } else {
              deleted = false;
            }
            ls.add(Document(
              key: rec['id'],
              userEmail: rec['useremail'],
              body: rec['body'],
              timestamp: rec['timestamp'],
              isDeleted: deleted,
            ));
          });
        });
        await db.close();
        return ls;
      });
    }
    return Future.error("Database not available");
  }

  Future<List<Document>> readAll() async {
    print("readAll " + _inited.toString());
    if (_inited) {
      bool deleted = false;
      return await openDatabase('np.db').then((db) async {
        List<Document> ls = [];
        await db.rawQuery('SELECT * FROM NOTES WHERE deleted = 0').then((rs) {
          //print(rs);
          rs.forEach((rec) {
            if (rec['deleted'] == 1) {
              deleted = true;
            } else {
              deleted = false;
            }
            Document doc = Document(
              key: rec['id'],
              userEmail: rec['useremail'],
              body: rec['body'],
              timestamp: rec['timestamp'],
              isDeleted: deleted,
            );
            //print(doc.key.toString() + " " + doc.body);
            ls.add(doc);
            //print(rec);
          });
        });
        await db.close();
        return ls;
      });
    }
    return Future.error("Database not available");
  }

  Future<List<Document>> readDeleted() async {
    print("readAll " + _inited.toString());
    if (_inited) {
      return await openDatabase('np.db').then((db) async {
        List<Document> ls = [];
        await db
            .rawQuery(
          'SELECT * FROM NOTES WHERE deleted = 1',
        )
            .then((rs) {
          //print(rs);
          rs.forEach((rec) {
            //print(rec);
            Document doc = Document(
              key: rec['id'],
              userEmail: rec['useremail'],
              body: rec['body'],
              timestamp: rec['timestamp'],
              isDeleted: rec['deleted'],
            );
            //print(doc.key.toString() + " " + doc.body);
            ls.add(doc);
            //print(rec);
          });
        });
        return ls;
      });
    }
    return Future.error("Database not available");
  }

  Future<void> syncAllDocuments(String userEmail) async {
    if (_inited) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference notes = firestore.collection('notes');
      Storage storage = await Storage.instance();
      List<Document> docList = await storage.readAll();

      try {
        await notes.where("userEmail", isEqualTo: userEmail).get().then(
          (value) {
            value.docs.forEach(
              (element) {
                FirebaseFirestore.instance
                    .collection('notes')
                    .doc(element.id)
                    .delete()
                    .then((value) => {print('success')});
              },
            );
          },
        );
        docList.forEach(
          (element) async {
            if (element.userEmail == userEmail) {
              element.timestamp = DateTime.now().microsecondsSinceEpoch;
              await notes.add(element.toMap());
            }
          },
        );
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> syncWithTimeStamp(String userEmail) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference notes = firestore.collection('notes');
    Storage storage = await Storage.instance();
    List<Document> docList = await storage.readAll();
    bool fileFound;
    try {
      await notes.where("userEmail", isEqualTo: userEmail).get().then(
        (value) async {
          for (Document docs in docList) {
            fileFound = false;
            value.docs.forEach((element) async {
              if (element.data()['id'] == docs.key) {
                if (element.data()['timestamp'] < docs.timestamp) {
                  DocumentReference document = FirebaseFirestore.instance
                      .collection('notes')
                      .doc(element.id);
                  await document.set(docs.toMap()).then((value) async {
                    fileFound = true;
                    if (!fileFound) {
                      await notes.add(docs.toMap());
                    }
                  });
                }
              }
            });
          }
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> clearDatabase(userEmail) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference notes = firestore.collection('notes');
    Storage storage = await Storage.instance();
    List<Document> docList = await storage.readAll();

    for (Document docs in docList) {
      if (docs.userEmail == userEmail) {
        await storage.del(docs.key);
      }
    }
    await notes.where("userEmail", isEqualTo: userEmail).get().then(
      (value) {
        value.docs.forEach(
          (element) {
            FirebaseFirestore.instance
                .collection('notes')
                .doc(element.id)
                .delete()
                .then((value) => {print('success')});
          },
        );
      },
    );
  }
}
