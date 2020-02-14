import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class protectorHomeScreen extends StatefulWidget {
  @override
  _protectorHomeScreenState createState() => _protectorHomeScreenState();
}

class _protectorHomeScreenState extends State<protectorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Protector screen"),
      ),
      body: CupertinoButton(
        // color: Color(0xff93E7AE),
          onPressed: () async {
            // widget._signOut();

            SharedPreferences prefs =
            await SharedPreferences.getInstance();
            await prefs.setBool('Loggedin', false);
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => LoginPage()));
          },
          child: Text("Sign Out")),
    );
  }
}
