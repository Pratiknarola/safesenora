import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(title: Text("safesenora")),
      body: Container(
        child: Center(
          child: Text(
            "User has been logged in email = ${user.email}",
            style: TextStyle(
                backgroundColor: Colors.white,
                fontSize: 14.0,
                color: Colors.black),
          ),
        ),
      ),
    );
  }
}
