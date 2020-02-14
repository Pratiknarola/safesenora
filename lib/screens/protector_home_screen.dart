import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  Position currentPosition;
  String currentAddress;

  _protectorHomeScreenState(this.user);

  String uid;
  var selectedItemId = 'Home';

  @override
  void initState() {
    super.initState();
    uid = user.uid;
  }

  getCurrentLocation() {
    //final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation).then((Position position) {
      setState(() {
        currentPosition = position;
      });

      getAddressFromLatLong();
    }).catchError((e) {
      print(e);
    });
  }

  getAddressFromLatLong() async {
    try {
      geolocator.placemarkFromCoordinates(currentPosition.latitude,currentPosition.longitude).then((List<Placemark> p){
        Placemark place = p[0];

        setState(() {
          currentAddress = "${place.locality},${place.postalCode},${place.country}";
        });
      });

    } catch(e){
      print(e);
    }
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
        ],
      )
    );
  }
}
