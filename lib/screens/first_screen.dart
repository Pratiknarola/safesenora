import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';

import '../auth/auth.dart';

class FirstScreen extends StatefulWidget {
  final Auth auth = new Auth();
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  FirebaseUser user;
  @override
  void initState() {
    super.initState();
    widget.auth.user().then((user) {
      setState(() {
        this.user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Prototype")),
      body: ListView(
        children: <Widget>[
          Text("User email ${user.uid}"),
          Padding(
            padding: EdgeInsets.all(20),
            child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 16),
              color: Colors.lightBlue,
              onPressed: () {
                setState(() {
                  _signout(context);
                });
              },
              elevation: 11,
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(40))),
              child: Text(
                "Log out",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          )
        ],
      )
    );
  }

  void _signout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
