import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notepad/Screens/note_list.dart';

class LoginScreen extends StatefulWidget {
  static final String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _auth;
  bool isUserSignedIn = false;

  initApp() async {
    FirebaseApp defaultApp = await Firebase.initializeApp();
    _auth = FirebaseAuth.instanceFor(app: defaultApp);

    checkIfUserIsSignedIn();
  }

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<User> _handleSignIn() async {
    User user;

    bool isSignedIn = await _googleSignIn.isSignedIn();

    setState(() {
      isUserSignedIn = isSignedIn;
    });
    if (isSignedIn) {
      user = _auth.currentUser;
    } else {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      user = (await _auth.signInWithCredential(credential)).user;
      isSignedIn = await _googleSignIn.isSignedIn();
      setState(() {
        isUserSignedIn = isSignedIn;
      });
    }

    return user;
  }

  void onGoogleSignIn(BuildContext context) async {
    User userLoggedIn = await _handleSignIn();
    print(userLoggedIn.email);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteList(
                  user: userLoggedIn,
                )));
    //setState(() {
    //  isUserSignedIn = userSignedIn == null ? true : false;
    //});
  }

  void checkIfUserIsSignedIn() async {
    var userSignedIn = await _googleSignIn.isSignedIn();

    setState(() {
      isUserSignedIn = userSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Login Screen'),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
          ),
          onPressed: () {
            onGoogleSignIn(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              children: [
                Image.asset(
                  'images/googleicon.jpg',
                  scale: 20,
                ),
                Text(
                  'Login with google',
                  style: TextStyle(fontSize: 30, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
