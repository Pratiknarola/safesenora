import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';
import 'package:prototype/screens/ProfilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    if (_seen) {
      if(!loggedin) {
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => new LoginPage()));
      }
      else{
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => new ProfilePage()));
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
