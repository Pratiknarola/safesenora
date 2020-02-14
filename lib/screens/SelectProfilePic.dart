import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectProfilPicture extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SelectProfilPictureState();
  }
}

class _SelectProfilPictureState extends State<SelectProfilPicture> {
  bool _isLoading = false;
  File newProfilPic;
  // CrudMethods crudObj = new CrudMethods();

  updateProfilPicture(picUrl, uid) {
    Map<String, dynamic> userMap = {'picture': picUrl};
    Firestore.instance
        .collection('girl_user')
        .document('$uid')
        .collection('user_info')
        .document(uid)
        .updateData(userMap)
        .catchError((e) {
      print(e);
    });
  }

  Future getImageFromGallery() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      newProfilPic = tempImage;
    });
  }

  Future getImageFromCamera() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      newProfilPic = tempImage;
    });
  }

  uploadImage() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('${user.uid}/profilePic/.jpg');
    final StorageUploadTask task = firebaseStorageRef.putFile(newProfilPic);
    if (task.isInProgress) {
      setState(() {
        _isLoading = true;
      });
    }
    var downloadUrl = await (await task.onComplete).ref.getDownloadURL();
    var url = downloadUrl.toString();
    updateProfilPicture(url, user.uid);
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(
            newProfilPic,
            height: 200,
            width: 200,
          ),
          _isLoading == false
              ? Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: RaisedButton(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Icon(
                      Icons.done,
                      color: Color(0xFF0fbc00),
                    ),
                    color: Color(0xFFe0fcdf),
                    textColor: Colors.black87,
                    onPressed: uploadImage,
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(top: 18.0),
                  child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: newProfilPic == null
                      ? Text('select an image')
                      : enableUpload(),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Icon(
                  Icons.folder,
                  color: Theme.of(context).primaryColor,
                ),
                color: Color(0xFFebdffc),
                textColor: Colors.black87,
                onPressed: getImageFromGallery,
              ),
              SizedBox(
                width: 25,
              ),
              RaisedButton(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).primaryColor,
                ),
                color: Color(0xFFebdffc),
                textColor: Colors.black87,
                onPressed: getImageFromCamera,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
