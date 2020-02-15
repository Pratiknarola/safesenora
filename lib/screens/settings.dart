import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/util/getDrawer.dart';

class SettingsPage extends StatefulWidget {
  FirebaseUser user;
  String role;

  SettingsPage(this.user, this.role);

  @override
  _SettingsPageState createState() => _SettingsPageState(user, role);
}

class _SettingsPageState extends State<SettingsPage> {
  FirebaseUser user;
  String role;

  _SettingsPageState(this.user, this.role);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(user, role).getdrawer(context),
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Text("This is setting page"),
          )
        ],
      ),
    );
  }
}
