import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class trustedMemberPage extends StatefulWidget {
  FirebaseUser user;

  trustedMemberPage(this.user);

  @override
  _trustedMemberPageState createState() => _trustedMemberPageState(user);
}

class _trustedMemberPageState extends State<trustedMemberPage> {

  FirebaseUser user;
  _trustedMemberPageState(this.user);

  Widget getUserTile(BuildContext context, int index){
    return ListTile(
      title: Text("Sample member") , // TODO get name of trusted member using index
      leading: CircleAvatar(), // TODO here we can use member's profile photo
      onTap: (){
        //TODO on tap girl user can see trusted member's profile and can remove him if want
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trusted Members"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.add),
            title: Text("Add trsuted members"),
            onTap: (){
              //TODO add trusted member in database with help of email or mobile
            },
          ),
          ListView.builder(
              itemCount: 0, //TODO get number of trusted members of user,
              itemBuilder: (context, index) => getUserTile(context, index))

        ],
      ),
    );
  }
}
