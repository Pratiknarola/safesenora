import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';
import 'package:prototype/auth/progresshud.dart';
import 'package:prototype/auth/setUserRole.dart';
import 'package:prototype/screens/protector_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as location_plugin;
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
        print("going to girl");
        FirebaseAuth.instance.currentUser().then((FirebaseUser currentUser) {
          Firestore.instance
              .collection('girl_user')
              .getDocuments()
              .then((QuerySnapshot qs_girl) {
            qs_girl.documents.forEach((DocumentSnapshot snap) {
              print("got in girl");
              if (snap.documentID == currentUser.uid) {
                print("making girl true");
                girl = true;
                //TODO sending user to girl screen so add token in girl_user collection user

                final FirebaseMessaging _firebaseMessaging =
                    FirebaseMessaging();
                _firebaseMessaging.getToken().then((token) {
                  print(token);
                  Firestore.instance
                      .collection('girl_user')
                      .document(currentUser.uid)
                      .setData({'NotifyToken': token}, merge: true);
                });

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => girlHomeScreen(currentUser)));
              }
            });
          });
          print("after girl girl: $girl and prot $protector");
          Firestore.instance
              .collection('protector')
              .getDocuments()
              .then((QuerySnapshot qs_protector) {
            qs_protector.documents.forEach((DocumentSnapshot snap) {
              if (snap.documentID == currentUser.uid) {
                protector = true;
                //TODO add new token in user in protector collection
                final FirebaseMessaging _firebaseMessaging =
                    FirebaseMessaging();
                _firebaseMessaging.getToken().then((token) {
                  print(token);
                  Firestore.instance
                      .collection('protector')
                      .document(currentUser.uid)
                      .setData({'NotifyToken': token}, merge: true);
                });
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            protectorHomeScreen(currentUser)));
              }
            });
            print("after prot girl $girl and prot $protector");
            if (!girl && !protector) {
              //after selecting role user will be sent to their own screen so
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
    var location = location_plugin.Location();
    location.changeSettings(
        accuracy: location_plugin.LocationAccuracy.NAVIGATION);
    location.requestPermission();
    return ProgressHUD(
      child: Container(),
      inAsyncCall: true,
      opacity: 0.0,
    );
  }
}
