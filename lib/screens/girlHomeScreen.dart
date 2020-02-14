import 'package:flutter/material.dart';
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
      body: Container(),
    );
  }
}
