import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';
import 'package:prototype/screens/ProfilePage1.dart';
import 'package:prototype/screens/girlHomeScreen.dart';
import 'package:prototype/screens/protector_home_screen.dart';

class setUserRole extends StatefulWidget {
  BuildContext context;
  FirebaseUser user;

  setUserRole(@required this.user);

  _setUserRoleState createState() => _setUserRoleState(context, this.user);
}

class _setUserRoleState extends State<setUserRole> {
  BuildContext context;
  FirebaseUser user;
  var _userRole;
  final _roles = ['as Girl', 'as Protector'];

  _setUserRoleState(this.context, this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.grey.shade600,
          ),
          Card(
            margin: EdgeInsets.only(top: 150, bottom: 150, left: 20, right: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            //color: Colors.deepPurple.shade200,
            color: Color(0xffacfbdf),
            elevation: 10,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  child: Text(
                    "Please select your Role",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  padding: EdgeInsets.only(top: 50),
                  alignment: Alignment.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.only(top: 50),
                  alignment: Alignment.center,
                  child: Text(
                    "I am joing this App as",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: ButtonTheme(
                        height: 50,
                        child: RaisedButton(
                          elevation: 10,
                          shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black)),
                          child: Text("Girl",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                          color: Colors.grey.shade400,
                          onPressed: () {
                            //TODO add role in database
                            Firestore.instance
                                .collection('girl_user')
                                .document(user.uid)
                                .setData({'time': DateTime.now()});

                            Firestore.instance
                                .collection('girl_user')
                                .document(user.uid)
                                .collection('user_info')
                                .document(user.uid)
                                .setData({
                              'name': '',
                              'picture':
                                  'http://knowafest.com/files/uploads/hack-2017112501.jpeg',
                              'email': '',
                              'surname': '',
                              'phone': 'girl_user',
                              'birth': '',
                            });
                            //TODO send on girl screen
                            if(user.isEmailVerified)
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => girlHomeScreen()));
                            else{
                                user.sendEmailVerification();
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                              }
                          },
                        ),
                      )),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: ButtonTheme(
                        height: 50,
                        child: RaisedButton(
                          elevation: 10,
                          shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black)),
                          child: Text("Protector",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                          color: Colors.grey.shade400,
                          onPressed: () {
                            Firestore.instance
                                .collection('protector')
                                .document(user.uid)
                                .setData({'time': DateTime.now()});

                            Firestore.instance
                                .collection('protector')
                                .document(user.uid)
                                .collection('user_info')
                                .document(user.uid)
                                .setData({
                              'name': '',
                              'picture':
                                  'http://knowafest.com/files/uploads/hack-2017112501.jpeg',
                              'email': '',
                              'surname': '',
                              'phone': 'Protector',
                              'birth': '',
                            });
                            //TODO send on protector screen
                            if(user.isEmailVerified)
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => protectorHomeScreen()));
                            else{
                              user.sendEmailVerification();
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                            }
                          },
                        ),
                      )),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
