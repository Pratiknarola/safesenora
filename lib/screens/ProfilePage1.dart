import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SelectProfilePic.dart';

class ProfilePage1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfilePage1State();
  }
}

class ProfilePage1State extends State<ProfilePage1> {
  String userId;

  // CrudMethods crudObj = new CrudMethods();
  String userMail = 'userMail';
  String _phoneNumber;
  String _name;
  String _surname;
  final _formKey = GlobalKey<FormState>();

  Future<String> getUid() {
    FirebaseAuth.instance.currentUser().then((user) {
      //Future.delayed(Duration(seconds: 2));

      setState(() {
        userId = user.uid;
        debugPrint("called setstate method");
      });
      print('userrrrrrrrrrrrrr $userId');
    });
  }

  @override
  void initState() {
    getUid();
  }

  String validateEmail(String value) {
    if (value.isEmpty ||
        !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
      return 'Enter a valid email';
    } else
      return null;
  }

  String validateName(String value) {
    if (value.isEmpty) {
      return 'Enter a valid value';
    } else
      return null;
  }

  String validatePhone(String value) {
    if (value.length != 10)
      return 'Enter a valid number';
    else
      return null;
  }

  void _openModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF737373)),
              color: Color(0xFF737373),
            ),
            child: Container(
              child: SelectProfilPicture(),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(25.0),
                  topRight: const Radius.circular(25.0),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build method executed with userid of $userId");
    print('user id is $userId');
    return userId == null
        ? CircularProgressIndicator()
        : StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('girl_user')
                .document('$userId')
                .collection('user_info')
                .snapshots(),
            builder: (context, snapshot) {
              debugPrint("i am in builder");
              debugPrint("in builder with $userId");

              if (!snapshot.hasData) {
                debugPrint("i have got some data");
                return LinearProgressIndicator();
                // print(userId);
//          return LinearProgressIndicator();
//        }

                //print(snapshot.data.documents[0]['Name']);

              } else {
                var userData = snapshot.data.documents;
                //print(userData);
                return pageConstruct(userData, context);
              }
            },
          );
  }

  Widget pageConstruct(userData, context) {
    Widget name() {
      return ListTile(
        leading: Icon(
          Icons.person,
          color: Color(0xff18352B),
          size: 35,
        ),
        title: Text(
          "Name",
          style: TextStyle(color: Colors.black, fontSize: 18.0),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Color(0xff18352B)),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              validator: validateName,
                              decoration: InputDecoration(hintText: 'Name'),
                              onSaved: (value) => _name = value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              child: Text(
                                "Save",
                                style: TextStyle(color: Color(0xff18352B)),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  Firestore.instance
                                      .collection('girl_user')
                                      .document(userId)
                                      .collection('user_info')
                                      .document(userId)
                                      .setData({'name': _name},
                                          merge: true).catchError((e) {
                                    print(e);
                                  });
                                  /*crudObj
                                      .createOrUpdateUserData({'name': _name});*/
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
          },
        ),
        subtitle: Text(
          userData[0]['name'],
          style: TextStyle(
            fontSize: 15.0,
            color: Color(0xff18352B),
          ),
        ),
      );
    }

    Widget surname() {
      return ListTile(
        leading: Icon(
          Icons.supervisor_account,
          color: Color(0xff18352B),
          size: 35,
        ),
        title: Text(
          "Surname",
          style: TextStyle(color: Colors.black, fontSize: 18.0),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Color(0xff18352B)),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              validator: validateName,
                              decoration:
                                  InputDecoration(hintText: 'Last Name'),
                              onSaved: (value) => _surname = value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              child: Text(
                                "Save",
                                style: TextStyle(color: Color(0xff18352B)),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();

                                  Firestore.instance
                                      .collection('girl_user')
                                      .document(userId)
                                      .collection('user_info')
                                      .document(userId)
                                      .setData({'surname': _surname},
                                          merge: true).catchError((e) {
                                    print(e);
                                  });
                                  /*crudObj.createOrUpdateUserData(
                                      {'surname': _surname});*/
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
          },
        ),
        subtitle: Text(
          userData[0]['surname'],
          style: TextStyle(fontSize: 15.0, color: Color(0xff18352B)),
        ),
      );
    }

    Widget phone() {
      return ListTile(
        leading: Icon(
          Icons.phone,
          color: Color(0xff18352B),
          size: 35,
        ),
        title: Text(
          "Number",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Color(0xff18352B)),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              validator: validatePhone,
                              decoration:
                                  InputDecoration(hintText: 'Mobile Number'),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _phoneNumber = value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              child: Text(
                                "Save",
                                style: TextStyle(color: Color(0xff18352B)),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  Firestore.instance
                                      .collection('girl_user')
                                      .document(userId)
                                      .collection('user_info')
                                      .document(userId)
                                      .setData({'phone': _phoneNumber},
                                          merge: true).catchError((e) {
                                    print(e);
                                  });

                                  /*
                                  crudObj.createOrUpdateUserData(
                                      {'phone': _phoneNumber});*/
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
          },
        ),
        subtitle: Text(
          userData[0]['phone'],
          style: TextStyle(fontSize: 15.0, color: Color(0xff18352B)),
        ),
      );
    }

    Widget mail() {
      return ListTile(
        leading: Icon(
          Icons.mail,
          color: Color(0xff18352B),
          size: 35,
        ),
        title: Text(
          'Mail',
          style: TextStyle(
              color: Color(0xff18352B),
              fontSize: 18.0,
              fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          userMail,
          style: TextStyle(fontSize: 15.0, color: Color(0xff18352B)),
        ),
      );
    }

    Widget birth() {
      return ListTile(
        leading: Icon(
          Icons.date_range,
          color: Color(0xff18352B),
          size: 35,
        ),
        title: Text(
          "Date of Birth",
          style: TextStyle(color: Colors.black, fontSize: 18.0),
        ),
        subtitle: Text(
          "birthText",
          //DateFormat('dd/MM/yyyy').format(userData['DOB'].toDate())
          style: TextStyle(fontSize: 15.0, color: Color(0xff18352B)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            SizedBox(
                height: 250,
                width: double.infinity,
                child: Image.network(
                  userData[0]['picture'],
                  fit: BoxFit.cover,
                )),
            Container(
              margin: EdgeInsets.fromLTRB(16.0, 200.0, 16.0, 16.0),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16.0),
                        margin: EdgeInsets.only(top: 16.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 96.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    userData[0]['name'] +
                                        userData[0]['surname'],
                                    style: Theme.of(context).textTheme.title,
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text("Product Designer"),
                                    subtitle: Text("Kathmandu"),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Text("5"),
                                      Text("Family members")
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Text("20"),
                                      Text("Trustful")
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Text("8"),
                                      Text("E-Numbers")
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 14, top: 1),
                        height: 80,
                        width: 80,
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SelectProfilPicture()));
                              // _openModalBottomSheet(context);
                            },
                            child: ClipRRect(
                              borderRadius: new BorderRadius.circular(10.0),
                              child: Image.network(
                                userData[0]['picture'],
                                fit: BoxFit.cover,
                              ),
                            )),
                      )
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text("User information"),
                        ),
                        Divider(),
                        name(),
                        surname(),
                        mail(),
                        phone(),
                        birth(),
                        Divider(),
                        Container(
                          //margin: EdgeInsets.only(left: 10, right: 10),
                          width: double.infinity,
                          child: CupertinoButton(
                              // color: Color(0xff93E7AE),
                              onPressed: () {
                                // widget._signOut();
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              child: Text("Sign Out")),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          ],
        ),
      ),
    );
  }
}
