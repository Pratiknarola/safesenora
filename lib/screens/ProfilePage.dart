import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:prototype/auth/login.dart';
import 'package:prototype/util/getDrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SelectProfilePic.dart';

class ProfilePage extends StatefulWidget {
  String role;

  ProfilePage(this.role);

  @override
  State<StatefulWidget> createState() {
    return ProfilePageState(role);
  }
}

class ProfilePageState extends State<ProfilePage> {
  String userId;
  String role;
  String collectionname;
  ProfilePageState(this.role); // CrudMethods crudObj = new CrudMethods();
  FirebaseUser current_user;
  String userMail = 'userMail';
  String _phoneNumber;
  String _name;
  String _surname;
  String dob;
  final _formKey = GlobalKey<FormState>();

  Future<String> getUid() {
    FirebaseAuth.instance.currentUser().then((user) {
      //Future.delayed(Duration(seconds: 2));
      current_user = user;
      setState(() {
        userId = user.uid;
        debugPrint("called setstate method");
        print('userrrrrrrrrrrrrr $userId');
      });
    });
  }

  @override
  void initState() {
    getUid();
    if (role == 'girl') {
      collectionname = 'girl_user';
    } else {
      collectionname = 'protector';
    }
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
                .collection('$collectionname')
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
                                      .collection('$collectionname')
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
                                      .collection('$collectionname')
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
          style: TextStyle(
            fontSize: 18.0,
          ),
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
                                      .collection('$collectionname')
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
          ),
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
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Color(0xff18352B)),
          onPressed: () {
            DatePicker.showDatePicker(context,
                theme: DatePickerTheme(
                  containerHeight: 210.0,
                ),
                showTitleActions: true,
                minTime: DateTime(1900, 1, 1),
                maxTime: DateTime.now(), onConfirm: (date) {
              print('confirm $dob');
              dob = '${date.day} - ${date.month} - ${date.year}';
              Firestore.instance
                  .collection('$collectionname')
                  .document(userId)
                  .collection('user_info')
                  .document(userId)
                  .setData({'birth': dob}, merge: true);
            }, currentTime: DateTime.now(), locale: LocaleType.en);
          },
        ),
        subtitle: Text(
          userData[0]['birth'],
          //DateFormat('dd/MM/yyyy').format(userData['DOB'].toDate())
          style: TextStyle(fontSize: 15.0, color: Color(0xff18352B)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      drawer: getDrawer(current_user, '$role').getdrawer(context),
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
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xffA8A8A4),
                                  Color(0xffACFBDF)
                                  //Color(0xffB6C8BC)
                                  //Color.fromRGBO(212, 63, 141, 1),
                                  //Color.fromRGBO(2, 80, 197, 1)
                                ]),
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
                              /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SelectProfilPicture()));*/
                              _openModalBottomSheet(context);
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
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xffA8A8A4),
                            Color(0xffACFBDF),
                            //Color(0xffB6C8BC)
                            //Color.fromRGBO(212, 63, 141, 1),
                            //Color.fromRGBO(2, 80, 197, 1)
                          ]),
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
                              onPressed: () async {
                                // widget._signOut();

                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('Loggedin', false);

                                Firestore.instance
                                    .collection(collectionname)
                                    .document(userId)
                                    .setData({'NotifyToken': 'null'},
                                        merge: true);
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()));
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
