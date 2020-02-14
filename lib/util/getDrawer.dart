import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/screens/ProfilePage.dart';
import 'package:prototype/screens/girl_home_screen.dart';
import 'package:prototype/screens/protector_home_screen.dart';
import 'package:prototype/screens/settings.dart';

class getDrawer {
  FirebaseUser user;
  String role;

  getDrawer(this.user, this.role);

  Widget getdrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: ListView(
              children: <Widget>[
                Center(
                  child: CircleAvatar(
                    //child: Image.network(//TODO add profile pic of person in center and add some decoration in drawer header ),
                    radius: 45,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  user.uid,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Monstserrat'),
                )
              ],
            ),
            decoration: BoxDecoration(
                color: Colors.blueAccent.shade100,
                image: DecorationImage(
                    image:
                        AssetImage("assets/images/Awesome-Blur-Background.jpg"),
                    fit: BoxFit.cover)),
          ),
          ListTile(
            title: Text("Home"),
            leading: Icon(Icons.home),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => (role == "girl")
                          ? girlHomeScreen(user)
                          : protectorHomeScreen(user)));
            },
          ),
          ListTile(
            title: Text("Profile"),
            leading: Icon(Icons.person_outline),
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
          ListTile(
            title: Text("Settings"),
            leading: Icon(Icons.settings),
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SettingsPage(user)));
            },
          ),
          role == 'girl'
              ? ListTile(
                  title: Text("Trusted members"),
                  leading: Icon(Icons.check_circle_outline),
                  onTap: () {},
                )
              : Container(),
          ListTile(
            title: Text("Support"),
            leading: Icon(Icons.info_outline),
          ),
          ListTile(
            title: Text("About us"),
            leading: Icon(Icons.supervised_user_circle),
          )
        ],
      ),
    );
  }
}
