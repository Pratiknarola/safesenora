import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:prototype/util/getDrawer.dart';

class trustedMemberPage extends StatefulWidget {
  FirebaseUser user;

  trustedMemberPage(this.user);

  @override
  _trustedMemberPageState createState() => _trustedMemberPageState(user);
}

class _trustedMemberPageState extends State<trustedMemberPage> {
  FirebaseUser user;
  ProgressDialog progressDialog;
  final _formKey = GlobalKey<FormState>();
  String mem_name, mem_surname, mem_id;
  Map<String, String> protectorList = new Map();
  var userInfoSnap;

  _trustedMemberPageState(this.user);

  void getUserData() {
    Firestore.instance
        .collection('girl_user')
        .document(user.uid)
        .collection('user_info')
        .document(user.uid)
        .get()
        .then((snap) {
      userInfoSnap = snap;
    });
  }

  void getProtectorList() {
    Firestore.instance.collection('user_list').getDocuments().then((qs) {
      var data = qs.documents;
      data.forEach((documentsnap) {
        if (documentsnap['type'] == "protector") {
          String key = '${documentsnap.documentID}',
              value = '${documentsnap['uid']}';
          print('$key and $value');

          print(
              'protector id is  ${documentsnap.documentID} ${documentsnap['uid']} ');
          //protectorList.update(key,()=>value);
          protectorList[key] = value;
          print('map is');
          print(protectorList);
        }
        //  protectorList.add({'${documentsnap.documentID}':'${documentsnap['uid']}'});
      });
    });
  }

  void updateGirlTrustedListNames() {
    Firestore.instance
        .collection('girl_user')
        .document(user.uid)
        .collection('trusted_member')
        .getDocuments()
        .then((qs_girlTrusted) {
      print('inside the 1st then');
      var document_snaps = qs_girlTrusted.documents;

      print('inside the 1st then ${document_snaps[0].documentID}');
      document_snaps.forEach((document_snap) {
        print('going to next step of then ${document_snap.documentID}');
        print('hello let me go');
        Firestore.instance
            .collection('protector')
            .document(document_snap.documentID)
            .collection('user_info')
            .getDocuments()
            .then((protector) {
          var trusted_data = protector.documents;
          print('inside 2nd then ${trusted_data[0]['name']}');
          document_snap.reference.setData({
            'name': '${trusted_data[0]['name']}',
            'surname': '${trusted_data[0]['surname']}',
          }, merge: true);
        });
      });
    });
  }

  @override
  void initState() {
    getUserData();
    getProtectorList();
    updateGirlTrustedListNames();
  }

  void setMemField(String memid, String value) {
    print("inside pratik memid $memid");
    Firestore.instance
        .collection('protector')
        .document('$memid')
        .collection('user_info')
        .getDocuments()
        .then((qs_protected) {
      var data = qs_protected.documents;
      mem_name = data[0]['name'];
      print("####################################");
      print(mem_name);
      mem_surname = data[0]['surname'];

      Firestore.instance
          .collection('girl_user')
          .document(user.uid)
          .collection('trusted_member')
          .document('$memid')
          .setData(
              {'name': mem_name, 'surname': mem_surname, 'identifier': value},
              merge: true).catchError((e) {
        print(e);
      });
      print('hellooo finally done');
    });
  }

  String validateMember(str) {
    print('inside validatemember');
    print('proytector list is ');
    print(protectorList);

    if (str.length > 0) {
      if (protectorList.keys.contains(str)) {
        mem_id = protectorList[str];
        return null;
      } else
        return "enter a valid member email or number";
    } else if (str == null || str == '') {
      return "member field can't be null";
    }
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    mem_id = null;
    return Scaffold(
        drawer: getDrawer(user, 'girl').getdrawer(context),
        key: _scaffoldKey,
        // backgroundColor: Colors.greenAccent,
        appBar: AppBar(
          title: Text("Trusted Members"),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            //TODO add trusted member in database with help of email or mobile

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
                              validator: validateMember,
                              decoration: InputDecoration(
                                  hintText: 'Number or Email-id'),
                              onSaved: (value) {
                                print("hello inside on saved $mem_id");
                                setMemField(mem_id, value);
                              },
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
                                //print("hello inside on pressed $mem_id");
                                if (_formKey.currentState.validate()) {
                                  //print("form validated");
                                  _formKey.currentState.save();
                                  setInProtectorList(mem_id,user.uid);
                                  //print("current name is $mem_name");
                                  //print("current id is $mem_id");
                                  //print("current surname is $mem_surname");
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
          label: Text('Add Member'),
          icon: Icon(Icons.add_circle_outline),
          backgroundColor: Colors.greenAccent,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('girl_user')
              .document(user.uid)
              .collection('trusted_member')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              print('caught inside null snapshots');
              return LinearProgressIndicator();
            } else {
              print('i have got the list data of trusted members');
              return buildProtectorList(snapshot.data.documents);
            }
          },
        ));
  }

  void deleteFromProtectorList(proid, userId) {
    Firestore.instance
        .collection('protector')
        .document('$proid')
        .collection('girl_list')
        .document(userId)
        .delete();
  }
  void setInProtectorList(proid,userId){
    Firestore.instance
        .collection('protector')
        .document(proid)
        .collection('girl_list')
        .document(userId)
        .setData({
      'name': userInfoSnap['name'],
      'surname': userInfoSnap['surname'],
      'picture': userInfoSnap['picture'],
      'battery': userInfoSnap['battery'],
      'phone': userInfoSnap['phone']
    }, merge: true);
  }

  Widget buildProtectorList(List<DocumentSnapshot> documents) {
    return ListView(
      children: documents.map((document) {
        print('name and surname is ${document['name']} ${document['surname']}');
        String docid = document.documentID,
            docname = document['name'],
            docsurname = document['surname'],
            docidentifier = document['identifier'];
        return new Dismissible(
            key: Key(document['identifier']),
            onDismissed: (DismissDirection dir) {
              document.reference.delete();
              deleteFromProtectorList(docid, user.uid);
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text("$docname $docsurname removed"),
                  action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        setState(() {
                          //adding to girl's trusted_member list
                          Firestore.instance
                              .collection('girl_user')
                              .document(user.uid)
                              .collection('trusted_member')
                              .document('$docid')
                              .setData({
                            'name': docname,
                            'surname': docsurname,
                            'identifier': docidentifier
                          }, merge: true);
                          //Adding to protector's girl_list
                          setInProtectorList(docid,user.uid);
                        });
                      }),
                ),
              );
            },
            background: Container(
              child: Icon(Icons.delete_outline),
              color: Colors.redAccent,
              alignment: Alignment.centerLeft,
            ),
            secondaryBackground: Container(
              child: Icon(Icons.delete_outline),
              color: Colors.redAccent,
              alignment: Alignment.centerRight,
            ),
            child: new ListTile(
              title: new Text("${document['name']} ${document['surname']}"),
              subtitle: new Text("${document['identifier']}"),
            ));
      }).toList(),
    );
  }
}
