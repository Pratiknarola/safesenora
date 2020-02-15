import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/screens/ProfilePage.dart';
import 'package:prototype/screens/girl_home_screen.dart';
import 'package:prototype/screens/protector_home_screen.dart';
import 'package:prototype/screens/settings.dart';
import 'package:prototype/screens/trusted_member.dart';
import 'package:prototype/util/oval_right_clipper.dart';

class getDrawer {
  FirebaseUser user;
  String role;
  final Color active = Colors.greenAccent;
  //final Color active = Color(0xff6C48AB);
  final TextStyle tStyle = TextStyle(color: Colors.greenAccent, fontSize: 16.0);
  final primary = Color(0xff696b9e);
  //final active = Color(0xfff29a94);
  var userData;

  getDrawer(this.user, this.role);

  Widget getdrawer(BuildContext context) {
    String userType = role == 'protector' ? 'protector' : 'girl_user';
    Firestore.instance
        .collection(userType)
        .document(user.uid)
        .collection('user_info')
        .document(user.uid)
        .get()
        .then((snap) {
      userData = snap;
    });
    return _buildDrawer(context);

    /*Drawer(
      child: ListView(
        children: <Widget>[
          */ /*DrawerHeader(
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
          ),*/ /*
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
                  MaterialPageRoute(builder: (context) => ProfilePage(role)));
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
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => trustedMemberPage(user)));
                  },
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
    );*/
  }

  _buildDrawer(context) {
    final String image =
        'http://knowafest.com/files/uploads/hack-2017112501.jpeg';
    return ClipPath(
      clipper: OvalRightBorderClipper(),
      child: Drawer(
        child: Container(
          padding: const EdgeInsets.only(left: 16.0, right: 40),
          decoration: BoxDecoration(
              color: primary, boxShadow: [BoxShadow(color: Colors.black45)]),
          width: 300,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.power_settings_new,
                        color: active,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 3, color: active),
                        gradient: LinearGradient(
                            colors: [Colors.greenAccent, Colors.indigo])),
                    child: Image.network(
                      userData == null ? image : userData['picture'],
                      width: 63,
                      height: 63,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    userData != null
                        ? '${userData['name']} ${userData['surname']}'
                        : 'Heyaa...',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                  SizedBox(height: 25.0),
                  GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(children: [
                          Icon(
                            Icons.home,
                            color: active,
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Container(
                              child: Text(
                                "Home",
                                style: tStyle,
                              ),
                            ),
                          )
                        ]),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => (role == "girl")
                                    ? girlHomeScreen(user)
                                    : protectorHomeScreen(user)));
                      }),
                  SizedBox(height: 3.0),
                  _buildDivider(),
                  SizedBox(height: 3.0),
                  GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(children: [
                          Icon(
                            Icons.person_outline,
                            color: active,
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Container(
                              child: Text(
                                "Profile",
                                style: tStyle,
                              ),
                            ),
                          )
                        ]),
                      ),
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => ProfilePage(role)));
                      }),
                  SizedBox(height: 3.0),
                  _buildDivider(),
                  SizedBox(height: 3.0),
                  GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(children: [
                          Icon(
                            Icons.settings,
                            color: active,
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Container(
                              child: Text(
                                "Settings",
                                style: tStyle,
                              ),
                            ),
                          )
                        ]),
                      ),
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => SettingsPage(user, role)));
                      }),
                  SizedBox(height: 3.0),
                  _buildDivider(),
                  SizedBox(height: 3.0),
                  role == 'girl'
                      ? GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: active,
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                child: Container(
                                  child: Text(
                                    "Trusted Members",
                                    style: tStyle,
                                  ),
                                ),
                              )
                            ]),
                          ),
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => trustedMemberPage(user)));
                          })
                      : Container(),
                  SizedBox(height: 3.0),
                  _buildDivider(),
                  SizedBox(height: 3.0),
                  GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(children: [
                          Icon(
                            Icons.info_outline,
                            color: active,
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Container(
                              child: Text(
                                "Support",
                                style: tStyle,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      onTap: () {}),
                  SizedBox(height: 3.0),
                  _buildDivider(),
                  SizedBox(height: 3.0),
                  GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(children: [
                          Icon(
                            Icons.supervised_user_circle,
                            color: active,
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Container(
                              child: Text(
                                "About us",
                                style: tStyle,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Divider _buildDivider() {
    return Divider(
      color: active,
    );
  }

/*  Widget _buildRow(IconData icon, String title) {
    final TextStyle tStyle = TextStyle(color: active, fontSize: 16.0);
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(children: [
          Icon(
            icon,
            color: active,
          ),
          SizedBox(width: 10.0),
          Text(
            title,
            style: tStyle,
          ),
        ]),
      ),
      onTap: () {},
    );
  }*/
}
