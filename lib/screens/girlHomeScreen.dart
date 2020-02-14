import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:drawerbehavior/drawerbehavior.dart';
//import 'package:drawerbehavior/menu_screen.dart';
class girlHomeScreen extends StatefulWidget {
  @override
  _girlHomeScreenState createState() => _girlHomeScreenState();
}

class _girlHomeScreenState extends State<girlHomeScreen> {
  /*final menu = new Menu(
    items: [
      MenuItem(
        id: 'Home',
        title: 'Home'
      ),
      MenuItem(
        id: 'Profile',
        title: 'Profile'
      ),
      MenuItem(
        id: 'Settings',
        title: 'Settings'
      ),
      MenuItem(
        id: 'Support',
        title: 'Support'
      ),
      MenuItem(
        id: 'About',
        title: 'About Us'
      ),
    ]
  );*/

  var selectedItemId = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Girl screen"),
      ),
      body:CupertinoButton(
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
