import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';
import 'package:prototype/util/getDrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class protectorHomeScreen extends StatefulWidget {

  FirebaseUser user;
  protectorHomeScreen(this.user);

  @override
  _protectorHomeScreenState createState() => _protectorHomeScreenState(user);
}

class _protectorHomeScreenState extends State<protectorHomeScreen> with SingleTickerProviderStateMixin {




  FirebaseUser user;

  _protectorHomeScreenState(this.user);

  String uid;
  var selectedItemId = 'Home';

  String _message = '';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _register() {
    _firebaseMessaging.getToken().then((token) => print(token));
  }
  void getMessage() {
    _firebaseMessaging.configure(
      // ignore: missing_return
      onMessage: (Map<String, dynamic> message){
        print("on message $message");
        showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              content: ListTile(
                title: Text(message['notification']['title']),
                subtitle: Text(message['notification']['body']),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Done"),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
          //TODO setstate to show changes according to levels and data
          }
        );
      },
      onResume: (Map<String, dynamic> message) async {
      print('on resume hello in resumed state $message');
      setState(() =>
      _message = "hello on resume ${message["notification"]["title"]}");
    }, onLaunch: (Map<String, dynamic> message) async {
    print('on launch on aunched state $message');
    setState(() => _message = message["notification"]["title"]);
    });
  }

  @override
  void initState() {
    super.initState();
    uid = user.uid;
    getMessage();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      drawer: getDrawer(user, 'protector').getdrawer(context),
      appBar: AppBar(
        title: Text("Protector screen"),
      ),
      body: ListView(
        children: <Widget>[
          /* StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance //TODO this is dummy query
                .collection('girl_user') //TODO change this as protector -> userid -> girluser ->
            //TODO -> uid of girls who have added this member as trusted member
                .document(user.uid)
                .collection('trusted_member')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                print('caught inside null snapshots');
                return LinearProgressIndicator();
              } else {
                print('i have got the list data of trusted members');
                return buildgirlList(snapshot.data.documents);
              }
            },
          ),
*/

          CupertinoButton(
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
          SizedBox(height: 20,),

        ],
      )
    );
  }

  Widget buildgirlList(List<DocumentSnapshot> documents) {
    // TODO build girl's list like did in trusted member in girl screen
  }


}
