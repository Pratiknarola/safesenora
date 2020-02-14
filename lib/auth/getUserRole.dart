import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class getUserRole extends StatefulWidget {
  BuildContext context;
  FirebaseUser user;

  getUserRole(@required this.user);

  @override
  _getUserRoleState createState() => _getUserRoleState(context, this.user);
}

class _getUserRoleState extends State<getUserRole> {
  BuildContext context;
  FirebaseUser user;
  var _userRole;
  final _roles = ['as Girl', 'as Protector'];

  _getUserRoleState(this.context, this.user);

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.black)),
                            child: Text("Girl",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white
                                )),
                            color: Colors.grey.shade400,
                            onPressed: () {
                              //TODO add role in database
                              //TODO send on girl screen
                            },
                          ),
                        )
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: ButtonTheme(
                            height: 50,
                            child: RaisedButton(
                              elevation: 10,
                              shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.black)),
                              child: Text("Protector",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white
                                  )),
                              color: Colors.grey.shade400,
                              onPressed: () {
                                //TODO add role in database
                                //TODO send on protector screen
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
