import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';
import 'package:prototype/auth/progresshud.dart';
import 'package:prototype/auth/setUserRole.dart';
import 'package:prototype/screens/protector_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'girl_home_screen.dart';
import 'intro.dart';

class setScreen extends StatefulWidget {
  @override
  _setScreenState createState() => _setScreenState();
}

class _setScreenState extends State<setScreen> {
  @override
  void initState() {
    super.initState();
    checkFirstSeen();
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    bool loggedin = (prefs.getBool("Loggedin") ?? false);
    bool girl;
    bool protector;

    if (_seen) {
      if (!loggedin) {
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => new LoginPage()));
      } else {
        FirebaseAuth.instance.currentUser().then((FirebaseUser currentUser) {
          Firestore.instance
              .collection('girl_user')
              .getDocuments()
              .then((QuerySnapshot qs_girl) {
            qs_girl.documents.forEach((DocumentSnapshot snap) {
              if (snap.documentID == currentUser.uid) {
                girl = true;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => girlHomeScreen(currentUser)));
              }
            });
          });
          Firestore.instance
              .collection('protector')
              .getDocuments()
              .then((QuerySnapshot qs_protector) {
            qs_protector.documents.forEach((DocumentSnapshot snap) {
              if (snap.documentID == currentUser.uid) {
                protector = true;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            protectorHomeScreen(currentUser)));
              }
            });

            if (!girl && !protector) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => setUserRole(currentUser)));
            }
          });
        });
      }
    } else {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IntroScreen(prefs)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Container(),
      inAsyncCall: true,
      opacity: 0.0,
    );
  }
}
