import 'dart:async';
import 'dart:math';

import 'package:async_loader/async_loader.dart';
import 'package:battery/battery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_plugin;
import 'package:prototype/util/getDrawer.dart';
import 'package:sms_maintained/sms.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import 'map_screen.dart';

// Import package

// Be informed when the state (full, charging, discharging) changes

class girlHomeScreen extends StatefulWidget {
  FirebaseUser user;

  girlHomeScreen(user) {
    if (user == null)
      FirebaseAuth.instance.currentUser().then((user) {
        this.user = user;
      });
    else {
      this.user = user;
    }
  }

  @override
  _girlHomeScreenState createState() => _girlHomeScreenState(user);
}

class _girlHomeScreenState extends State<girlHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polyline = {};

  LatLng _lastmapposition = _center;
  List<LatLng> latlng = List();

  double lat, lng;
  static LatLng _center;
  String address;
  String link;
  double distance = 0;
  FirebaseUser user;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  var battery;
  var pastBatteryLevel;
  var userData;
  var TPhoneNumbers = [];

  _girlHomeScreenState(this.user);

  location_plugin.Location location;
  bool isForegroundServiceOn = false;
  String uid;
  var selectedItemId = 'Home';

  bool _isvisible = false;
  bool level1 = false;
  bool level2 = false;
  bool level3 = false;

  void showToast() {
    setState(() {
      _isvisible = !_isvisible;
    });
  }

  double deg2rad(double deg) {
    const double pi = 3.1415926535897932;
    return deg * (pi / 180);
  }

  double distInKm(LatLng coord1, LatLng coord2) {
    const R = 6371; // Radius of the earth in km
    var dLat = deg2rad(coord2.latitude - coord1.latitude);
    var dLng = deg2rad(coord2.longitude - coord1.longitude);
    var a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(deg2rad(coord1.latitude)) *
            cos(deg2rad(coord2.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c;
    return d;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); //TODO ask nikhar about this line
    super.initState();

    //TODO Connctivity SOS button

    /**************Getting the phone nubers of trusted users**************************/
    var query = Firestore.instance.collection('girl_user').document(user.uid);
    query.collection('user_info').document(user.uid).get().then((user_snap) {
      userData = user_snap;
    });
    query.collection('trusted_member').getDocuments().then((qs_snap) {
      var list = qs_snap.documents;

      for (var snap in list) {
        var id = snap.documentID;
        Firestore.instance
            .collection('protector')
            .document(id)
            .collection('user_info')
            .document(id)
            .get()
            .then((doc_snap) {
          //if (validateNumber(doc_snap['phone']))
          TPhoneNumbers.add(doc_snap['phone']);
        });
      }
    });

    /*********************************************************************************/

    /*************java location testing*****************/ /* //not in use...
    const platform = const MethodChannel("platformlocation");
    print("java location testing");
    print("channel created");
    try {                       //Foreground service keeps app running in background anyway...
          () async {
        print("calling letlastlocation");
        print(platform);
        //await platform.invokeMethod("startLocationService");
        print("location call done");
      }();
    } catch (e) {
      print("error in java lastlocation");
      print(e);
    }*/

    /*****************Battery part *******************/
    updateBattery();

    /************************************************/
    uid = user.uid;
    location = location_plugin.Location();
    location.changeSettings(
        interval: 10000, accuracy: location_plugin.LocationAccuracy.NAVIGATION);
    location.requestPermission().then((granted) {
      if (granted) {
        location.onLocationChanged().listen((locationData) {
          if (locationData != null) {
            lat = locationData.latitude;
            lng = locationData.longitude;

            if (_center == null) {
              _center = LatLng(lat, lng);
            }
            try {
              if (distInKm(LatLng(lat, lng), _center) > 0.007) {
                distance = distInKm(LatLng(lat, lng), _center);
                print(lat);
                print(lng);
                print(DateTime.now());

                link =
                "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
                if (_center != null) latlng.add(_center);
                setState(() {
                  _center = LatLng(lat, lng);
                  print(
                      "Current center is ${_center.latitude} and ${_center.longitude}");
                  latlng.add(_center);
                  if (latlng.length > 100) latlng.removeAt(0);
                  print("lat and lng");
                  //var now = new DateTime.now();
                  //print(now);
                  _onAddMarkerButtonPressed();
                });
              }
            } catch (e) {
              print(e);
              debugPrint("ERROR IN GIRL HOME SCREEN IN INITSTATE");
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }

  /* bool validateNumber(number) {
    String pattern =
        r'/^((\+*)((0[ -]+)*|(91 )*)(\d{12}+|\d{10}+))|\d{5}([- ]*)\d{6}$/';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(number))
      return false;
    else
      return true;
  }*/

  void send_sms(String mesej) {
    for (var address in TPhoneNumbers) {
      SmsSender sender = new SmsSender();
      SmsMessage message = new SmsMessage(address, mesej);
      /* message.onStateChanged.listen((state) {
        if (state == SmsMessageState.Sent) {
          print("SMS is sent!");
        } else if (state == SmsMessageState.Delivered) {
          print("SMS is delivered!");
        }
      });*/
      /*sender.onSmsDelivered.listen((SmsMessage message) {
        print('${message.address} received your message.');
      });*/
      sender.sendSms(message);
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    location.getLocation().then((loc) {
      _center = LatLng(loc.latitude, loc.longitude);
    });
    //_center = LatLng(lat, lng);
    /*final markerOptions = Marker(
        markerId: MarkerId(k),
        position: LatLng(lat, lng)
    );*/
    //markers[k] = markerOptions;
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastmapposition.toString()),
          position: _lastmapposition,
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  //bool setting = await location.changeSettings(accuracy: LocationAccuracy.NAVIGATION);
  LocationServices() {
    location.getLocation().then((loc) {
      lat = loc.latitude;
      lng = loc.longitude;
    });
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
  new GlobalKey<AsyncLoaderState>();

  @override
  Widget build(BuildContext context) {
    LocationServices();

    updateBattery();

//akg19082000#

    return Scaffold(
      appBar: AppBar(
        title: Text("Girl Home Screen"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.location_on),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => girlMapScreen()),
                );
              }),
        ],
      ),
      drawer: getDrawer(user, 'girl').getdrawer(context),
      body: Container(
        padding: EdgeInsets.all(2.0),
        child: Stack(
          //color: Colors.green,
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        child: Container(
                          // padding: EdgeInsets.only(left:,
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: MediaQuery.of(context).size.width * 0.40,
                          decoration: new BoxDecoration(
                              border: new Border.all(
                                color: Colors.pink.shade200,
                                width: 5.0,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: new BorderRadius.circular(20.0)),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Stack(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2, top: 2),
                                  child: WaveWidget(
                                    config: CustomConfig(
                                      gradients: [
                                        [Colors.red, Color(0xEEF44336)],
                                        [Colors.red[800], Color(0x77E57373)],
                                        [Colors.orange, Color(0x66FF9800)],
                                        [Colors.yellow, Color(0x55FFEB3B)]
                                      ],
                                      durations: [35000, 19440, 10800, 6000],
                                      heightPercentages: [
                                        0.20,
                                        0.23,
                                        0.25,
                                        0.30
                                      ],
                                      blur:
                                      MaskFilter.blur(BlurStyle.outer, 10),
                                      gradientBegin: Alignment.bottomLeft,
                                      gradientEnd: Alignment.topRight,
                                    ),
                                    waveAmplitude: 8,
                                    backgroundColor: Colors.white,
                                    size:
                                    Size(double.infinity, double.infinity),
                                  ),
                                ),
                                Center(
                                  child: Text("Level 1",
                                      style: TextStyle(
                                          color: Colors.pink.shade300,
                                          fontSize: 24,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.center,
                                      textScaleFactor: 2.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          print("making lvel 1 true in firestore");
                          Firestore.instance
                              .collection('girl_user')
                              .document(user.uid)
                              .collection('level_info')
                              .document(user.uid)
                              .setData({'level1': true}, merge: true);
                          print("addinglocation info in firestor level ");
                          try{
                            startLocationUpdate();
                          }catch(e){print("error in location update "); print(e);}

                          const platform = const MethodChannel('platformlocation');
                          print("platform method channel ");
                          isForegroundServiceOn = true;
                          platform.invokeMethod("startForegroundService");
                          print("method invoked");
                          updateBatteryperiodic();
                          /*setState(() {
                            level_1_pressed = !level_1_pressed;
                            print("level 1 pressed");
                          });*/
                        },
                      ),
                      //ToDo I Am safe button to stop foreground service
                      GestureDetector(
                        child: Container(
                          // padding: EdgeInsets.only(left:,
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: MediaQuery.of(context).size.width * 0.40,
                          decoration: new BoxDecoration(
                              border: new Border.all(
                                color: Colors.pink.shade200,
                                width: 5.0,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: new BorderRadius.circular(20.0)),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Stack(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2, top: 2),
                                  child: WaveWidget(
                                    config: CustomConfig(
                                      gradients: [
                                        [Colors.red, Color(0xEEF44336)],
                                        [Colors.red[800], Color(0x77E57373)],
                                        [Colors.orange, Color(0x66FF9800)],
                                        [Colors.yellow, Color(0x55FFEB3B)]
                                      ],
                                      durations: [35000, 19440, 10800, 6000],
                                      heightPercentages: [
                                        0.20,
                                        0.23,
                                        0.25,
                                        0.30
                                      ],
                                      blur:
                                      MaskFilter.blur(BlurStyle.outer, 10),
                                      gradientBegin: Alignment.bottomLeft,
                                      gradientEnd: Alignment.topRight,
                                    ),
                                    waveAmplitude: 8,
                                    backgroundColor: Colors.white,
                                    size:
                                    Size(double.infinity, double.infinity),
                                  ),
                                ),
                                Center(
                                  child: Text("Level 2",
                                      style: TextStyle(
                                          color: Colors.pink.shade300,
                                          fontSize: 23,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.center,
                                      textScaleFactor: 2.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          Firestore.instance
                              .collection('girl_user')
                              .document(user.uid)
                              .collection('level_info')
                              .document(user.uid)
                              .setData({'level2': true}, merge: true);
                          setState(() {
                            level2 = true;
                            level1 = true;
                            print("level 2 pressed");
                          });
                        },
                      )
                    ],
                  ),
                  GestureDetector(
                    child: Container(
                      // padding: EdgeInsets.only(left:,
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: MediaQuery.of(context).size.width * 0.87,
                      decoration: new BoxDecoration(
                          border: new Border.all(
                            color: Colors.pink.shade200,
                            width: 5.0,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: new BorderRadius.circular(20.0)),
                      child: Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(bottom: 2, top: 2),
                              child: WaveWidget(
                                config: CustomConfig(
                                  gradients: [
                                    [Colors.red, Color(0xEEF44336)],
                                    [Colors.red[800], Color(0x77E57373)],
                                    [Colors.orange, Color(0x66FF9800)],
                                    [Colors.yellow, Color(0x55FFEB3B)]
                                  ],
                                  durations: [35000, 19440, 10800, 6000],
                                  heightPercentages: [0.20, 0.23, 0.25, 0.30],
                                  blur: MaskFilter.blur(BlurStyle.outer, 10),
                                  gradientBegin: Alignment.bottomLeft,
                                  gradientEnd: Alignment.topRight,
                                ),
                                waveAmplitude: 8,
                                backgroundColor: Colors.white,
                                size: Size(double.infinity, double.infinity),
                              ),
                            ),
                            Center(
                              child: Text("Level 3",
                                  style: TextStyle(
                                      color: Colors.pink.shade300,
                                      fontSize: 30,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w400),
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 2.0),
                            ),

                            /*Align(
                            alignment: Alignment.center,
                            child: Container(),
                          ),*/
                            /*new Container(
                            child: Text(
                              "Level 3",
                              textAlign: TextAlign.justify,
                              textScaleFactor: 2.0,
                            ),
                          )*/
                          ],
                        ),
                      ),
                    ),
                    onDoubleTap: () {
                      Firestore.instance
                          .collection('girl_user')
                          .document(user.uid)
                          .collection('level_info')
                          .document(user.uid)
                          .setData({'level3': true}, merge: true);
                      const platform = const MethodChannel('platformlocation');
                      print("platform method channel ");
                      platform.invokeMethod("stopForegroundService");
                      isForegroundServiceOn = false;
                      setState(() {
                        level3 = true;
                        print("level 3 pressed");
                      });
                    },
                  ),
                  GestureDetector(
                    child: Container(
                      // padding: EdgeInsets.only(left:,
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.87,
                      decoration: new BoxDecoration(
                          border: new Border.all(
                            color: Colors.pink.shade200,
                            width: 5.0,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: new BorderRadius.circular(20.0)),
                      child: Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(bottom: 2, top: 2),
                              child: WaveWidget(
                                config: CustomConfig(
                                  gradients: [
                                    [Colors.green, Colors.greenAccent],
                                    [Colors.green[800], Color(0x77E57373)],
                                    [Colors.lightGreen, Color(0x66FF9800)],
                                    [Colors.yellow, Color(0x55FFEB3B)]
                                  ],
                                  durations: [35000, 19440, 10800, 6000],
                                  heightPercentages: [0.20, 0.23, 0.25, 0.30],
                                  blur: MaskFilter.blur(BlurStyle.outer, 10),
                                  gradientBegin: Alignment.bottomLeft,
                                  gradientEnd: Alignment.topRight,
                                ),
                                waveAmplitude: 8,
                                backgroundColor: Colors.white,
                                size: Size(double.infinity, double.infinity),
                              ),
                            ),
                            Center(
                              child: Text("I m safe now",
                                  style: TextStyle(
                                      color: Colors.pink.shade300,
                                      fontSize: 30,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w400),
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 2.0),
                            ),

                            /*Align(
                            alignment: Alignment.center,
                            child: Container(),
                          ),*/
                            /*new Container(
                            child: Text(
                              "Level 3",
                              textAlign: TextAlign.justify,
                              textScaleFactor: 2.0,
                            ),
                          )*/
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      Firestore.instance
                          .collection('girl_user')
                          .document(user.uid)
                          .collection('level_info')
                          .document(user.uid)
                          .setData({
                        'level3': false,
                        'level1': false,
                        'level2': false
                      }, merge: true);
                      Firestore.instance
                          .collection('girl_user')
                          .document(user.uid)
                          .collection('agreed_user')
                          .getDocuments()
                          .then((snapshot) {
                        for (DocumentSnapshot ds in snapshot.documents) {
                          ds.reference.delete();
                        }
                      });
                      Firestore.instance
                          .collection('girl_user')
                          .document(user.uid)
                          .collection('allowed_user')
                          .getDocuments()
                          .then((snapshot) {
                        for (DocumentSnapshot ds in snapshot.documents) {
                          Firestore.instance
                              .collection('protector')
                              .document(ds.documentID)
                              .collection('helping_list')
                              .document(user.uid)
                              .delete();
                          ds.reference.delete();
                        }
                      });

                      setState(() {
                        level1 = false;
                        level2 = false;
                        level3 = false;
                        print("level 3 pressed");
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateBattery() async {
    print("in update battery");
    battery = Battery();
    var currentBatteryLevel = await battery.batteryLevel;
    print("in update battery with $currentBatteryLevel");
    Firestore.instance
        .collection('girl_user')
        .document(user.uid)
        .collection('user_info')
        .document(user.uid)
        .setData({'battery': '$currentBatteryLevel'}, merge: true);
    //Future.delayed(Duration(minutes: 10),() { print("10 mins are done");});
  }

  void updateBatteryperiodic()  {
    Battery().onBatteryStateChanged.listen((newstate) async {
      var current = await Battery().batteryLevel;
      Firestore.instance
          .collection('girl_user')
          .document(user.uid)
          .collection('user_info')
          .document(user.uid).setData({'battery':'$current'},merge: true);

    });

    /*while(isForegroundServiceOn) {

  Future<void> updateBatteryperiodic() async {
    while (isForegroundServiceOn) {
      await Future.delayed(Duration(minutes: 15), () {
        updateBattery();
      });
    }*/
  }

  void startLocationUpdate() {
    location_plugin.Location().onLocationChanged().listen((loc){
      Firestore.instance.collection("girl_user")
          .document(user.uid)
          .collection("location_info")
          .document(user.uid)
          .setData({
        "last_location": GeoPoint(loc.latitude, loc.longitude),
        "last_update": DateTime.now()
      });
    });


  }

/*//Future.delayed(Duration(seconds: 10), (){
        while(isForegroundServiceOn){
          location_plugin.Location().getLocation().then((loc){
            Firestore.instance.collection("girl_user")
                .document(user.uid)
                .collection("location_info")
                .document(user.uid)
                .setData({
              "last_location": GeoPoint(loc.latitude, loc.longitude),
              "last_update": DateTime.now()
            });
          });
      }});
    }*/

}