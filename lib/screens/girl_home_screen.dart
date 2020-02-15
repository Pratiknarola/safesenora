import 'dart:async';
import 'dart:math';

import 'package:async_loader/async_loader.dart';
import 'package:battery/battery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_plugin;
import 'package:prototype/util/getDrawer.dart';
import 'package:url_launcher/url_launcher.dart';

/*class Visibility extends StatefulWidget {
  @override
  Visibility createState() {
    return _visible();
  }
}

class _visible extends State {
  bool _isvisible = false;
  void showToast() {
    setState(() {
      _isvisible = !_isvisible;
    });
  }
  @override
  Widget build(BuildContext context) {
    return girlHomeScreen();
  }
}*/

// Import package

// Be informed when the state (full, charging, discharging) changes

class girlHomeScreen extends StatefulWidget {
  FirebaseUser user;

  girlHomeScreen(this.user);

  @override
  _girlHomeScreenState createState() => _girlHomeScreenState(user);
}

class _girlHomeScreenState extends State<girlHomeScreen>
    with SingleTickerProviderStateMixin {
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

  _girlHomeScreenState(this.user);

  location_plugin.Location location;
  String uid;
  var selectedItemId = 'Home';

  bool _isvisible = false;

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
    super.initState();

    /*****************Battery part *******************/
    battery = Battery();
    () async {
      pastBatteryLevel = await battery.batteryLevel;
      print('in init state with battery $pastBatteryLevel');
    }();

    battery.onBatteryStateChanged.listen((BatteryState state) async {
      if (state == BatteryState.discharging) {
        var currentBatteryLevel = await battery.batteryLevel;
        if (currentBatteryLevel >= 50 &&
            (pastBatteryLevel - currentBatteryLevel > 2)) {
          pastBatteryLevel = currentBatteryLevel;
          Firestore.instance
              .collection('girl_user')
              .document(user.uid)
              .collection('level_info')
              .document(user.uid)
              .setData({'battery': '$currentBatteryLevel'}, merge: true);
        } else if (currentBatteryLevel < 50) {
          pastBatteryLevel = currentBatteryLevel;
          Firestore.instance
              .collection('girl_user')
              .document(user.uid)
              .collection('level_info')
              .document(user.uid)
              .setData({'battery': '$currentBatteryLevel'}, merge: true);
        }
      }
    });

    /************************************************/
    uid = user.uid;
    location = location_plugin.Location();
    location.changeSettings(
        accuracy: location_plugin.LocationAccuracy.NAVIGATION);
    location.requestPermission().then((granted) {
      if (granted) {
        location.onLocationChanged().listen((locationData) {
          if (locationData != null) {
            lat = locationData.latitude;
            lng = locationData.longitude;
            try {
              if (distInKm(LatLng(lat, lng), _center) > 0.007) {
                distance = distInKm(LatLng(lat, lng), _center);
                print(lat);
                print(lng);
                Geolocator()
                    .placemarkFromCoordinates(lat, lng)
                    .then((placemark) {
                  var gatsby = placemark[0].name +
                      ", " +
                      placemark[0].subLocality +
                      ", " +
                      placemark[0].locality +
                      ", " +
                      placemark[0].administrativeArea +
                      ", " +
                      placemark[0].country +
                      " - " +
                      placemark[0].postalCode;
                  address =
                      "I am in emergency!\nThis is my current location: " +
                          gatsby +
                          "\nCoordinates: " +
                          lat.toString() +
                          "," +
                          lng.toString();
                  link =
                      "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
                });
                if (_center != null) latlng.add(_center);
                setState(() {
                  _center = LatLng(lat, lng);
                  print(
                      "Current center is ${_center.latitude} and ${_center.longitude}");
                  latlng.add(_center);
                  if (latlng.length > 100) latlng.removeAt(0);
                  print("lat and lng");
                  _onAddMarkerButtonPressed();
                });
              }
            } catch (e) {
              debugPrint("ERROR IN GIRL HOME SCREEN IN INITSTATE");
            }
          }
        });
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _center = LatLng(lat, lng);
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
      _polyline.add(Polyline(
          width: 5,
          polylineId: PolylineId(_lastmapposition.toString()),
          visible: true,
          points: latlng,
          color: Colors.blue));
    });
  }

  //bool setting = await location.changeSettings(accuracy: LocationAccuracy.NAVIGATION);
  LocationServices() {
    location.requestPermission().then((granted) {
      if (granted) {
        location.onLocationChanged().listen((locationData) {
          if (locationData != null) {
            lat = locationData.latitude;
            lng = locationData.longitude;
            print(lat);
            print(lng);
            print("lat and lng");
          }
        });
      }
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
    //_center = LatLng(lat, lng);
    //print("Lat: ${_center.latitude} and Lng: ${_center.longitude}");
    return Scaffold(
      drawer: getDrawer(user, 'girl').getdrawer(context),
      appBar: AppBar(
        title: Text("Girl screen"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.33,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Visibility(
                  visible: !_isvisible,
                  child: RaisedButton(
                    child: Text('Show MapView'),
                    onPressed: showToast,
                  ),
                ),
                Visibility(
                    visible: _isvisible,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: GoogleMap(
                        polylines: _polyline,
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                            target: _center == null ? LatLng(0, 0) : _center,
                            zoom: 11.5),
                        compassEnabled: true,
                        //markers:
                      ),
                    )),
                Visibility(
                    visible: _isvisible,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          CupertinoButton(
                            child: Text("Open in maps"),
                            onPressed: () {
                              openMap(lat, lng);
                            },
                          ),
                          CupertinoButton(
                            child: Text("add marker"),
                            onPressed: _onAddMarkerButtonPressed,
                          ),
                          RaisedButton(
                            child: Text('hide map'),
                            onPressed: showToast,
                          ),
<<<<<<< HEAD
                        ),
                        RaisedButton(
                          child: Text("Level 1"),
                          onPressed: () {
                            Firestore.instance
                                .collection('girl_user')
                                .document(user.uid)
                                .collection('level_info')
                                .document(user.uid)
                                .setData({'level1': true}, merge: true);
                          },
                        ),
                        RaisedButton(
                          child: Text("Level 2"),
                          onPressed: () {
                            Firestore.instance
                                .collection('girl_user')
                                .document(user.uid)
                                .collection('level_info')
                                .document(user.uid)
                                .setData({'level2': true}, merge: true);
                          },
                        ),
                        RaisedButton(
                            child: Text("Level 3"),
                            onPressed: () {
                              Firestore.instance
                                  .collection('girl_user')
                                  .document(user.uid)
                                  .collection('level_info')
                                  .document(user.uid)
                                  .setData({'level3': true}, merge: true);
                            }),
                      ],
                    ),
=======
                        ])),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.54,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    _center == null
                        ? "loading"
                        : "Lat: ${_center.latitude} and Lng: ${_center.longitude}",
                    style: TextStyle(fontSize: 20),
>>>>>>> 1e0917c855f6e397c2aa25ee654bbc556ca669b2
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Link: $link",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                RaisedButton(
                  child: Text("Reload"),
                  onPressed: (){
                    setState(() {
                      if(lat != null && lng != null){
                        _center = LatLng(lat, lng);
                      }
                      else{
                        LocationServices();
                      }
                    });
                  },
                ),
                RaisedButton(
                  child: Text("Reset Levels"),
                  onPressed: (){
                    Firestore.instance
                        .collection('girl_user')
                        .document(user.uid)
                        .collection('level_info')
                        .document(user.uid)
                        .setData({'level1': false, 'level2': false, 'level3': false}, merge: true);
                  },
                ),
                RaisedButton(
                  child: Text("Level 1"),
                  onPressed: () {
                    Firestore.instance
                        .collection('girl_user')
                        .document(user.uid)
                        .collection('level_info')
                        .document(user.uid)
                        .setData({'level1': true}, merge: true);
                  },
                ),
                RaisedButton(
                  child: Text("Level 2"),
                  onPressed: () {
                    Firestore.instance
                        .collection('girl_user')
                        .document(user.uid)
                        .collection('level_info')
                        .document(user.uid)
                        .setData({'level2': true}, merge: true);
                  },
                ),
                RaisedButton(
                    child: Text("Level 3"),
                    onPressed: () {
                      Firestore.instance
                          .collection('girl_user')
                          .document(user.uid)
                          .collection('level_info')
                          .document(user.uid)
                          .setData({'level3': true}, merge: true);
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
