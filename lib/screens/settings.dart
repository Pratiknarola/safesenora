import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsPage extends StatefulWidget {
  FirebaseUser user;


  SettingsPage(this.user);

  @override
  _SettingsPageState createState() => _SettingsPageState(user);
}

class _SettingsPageState extends State<SettingsPage> {
  FirebaseUser user;

  _SettingsPageState(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings"
        ),
      ),
      body: ListView(
        children: <Widget>[
          Center(child: Text("This is setting page"),)
        ],
      ),
    );
  }
}
