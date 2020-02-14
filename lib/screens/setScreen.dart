import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';
import 'package:prototype/auth/setUserRole.dart';
import 'package:prototype/screens/ProfilePage1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProfilePage1.dart';
import 'girlHomeScreen.dart';
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
  Future<String> getRole() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    bool girl_user, protector;
    QuerySnapshot qs_girl =
        await Firestore.instance.collection('girl_user').getDocuments();
    qs_girl.documents.forEach((DocumentSnapshot snap) {
      if (snap.documentID == user.uid) {debugPrint("I am girl user"); return 'girl';}
    });


    QuerySnapshot qs_protect =
        await Firestore.instance.collection('protector').getDocuments();
    qs_protect.documents.forEach((DocumentSnapshot snap) {
      if (snap.documentID == user.uid) {debugPrint("I am protector user"); return 'protector';}
    });
  }


  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    bool loggedin = (prefs.getBool("Loggedin") ?? false);

    if (_seen) {
      if (!loggedin) {
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => new LoginPage()));
      }
      else{

        FirebaseAuth.instance.currentUser().then((FirebaseUser currentUser){
          Firestore.instance
              .collection('girl_user')
              .getDocuments()
              .then((QuerySnapshot qs_girl) {
            qs_girl.documents.forEach((DocumentSnapshot snap) {
              if (snap.documentID == currentUser.uid) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => ProfilePage1()));
              }
            });
          });
          Firestore.instance
              .collection('protector')
              .getDocuments()
              .then((QuerySnapshot qs_protector) {
            qs_protector.documents.forEach((DocumentSnapshot snap) {
              if (snap.documentID == currentUser.uid) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => girlHomeScreen()));
              }
            });
          });

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => setUserRole(currentUser)));
        });




      }
    } else {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IntroScreen(prefs)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
