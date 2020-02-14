import 'dart:async';

import 'package:async_loader/async_loader.dart';
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
  FirebaseUser user;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

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

  @override
  void initState() {
    super.initState();
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
            print(lat);
            print(lng);
            if (_center != null) latlng.add(_center);
            setState(() {
              _center = LatLng(lat, lng);
              print(
                  "Current center is ${_center.latitude} and ${_center.longitude}");
              latlng.add(_center);
              print("lat and lng");
              _onAddMarkerButtonPressed();
            });
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
          polylineId: PolylineId(_lastmapposition.toString()),
          visible: true,
          points: latlng,
          color: Colors.blue));
    });
  }

  //bool setting = await location.changeSettings(accuracy: LocationAccuracy.NAVIGATION);
  LocationServices(k) {
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
    var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async {
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
                  print(lat);
                  print(lng);
                  if (_center != null) latlng.add(_center);
                  setState(() {
                    _center = LatLng(lat, lng);
                    print(
                        "Current center is ${_center.latitude} and ${_center.longitude}");
                    latlng.add(_center);
                    print("lat and lng");
                    _onAddMarkerButtonPressed();
                  });
                }
              });
            }
          });
        },
        renderLoad: () => new CircularProgressIndicator(),
        renderError: ([error]) {
          return Card(
            child: RaisedButton(
              child: Text("Retry"),
              onPressed: () {
                _asyncLoaderState.currentState.reloadState();
              },
            ),
          );
        },
        renderSuccess: ({data}) {
          Geolocator().placemarkFromCoordinates(lat, lng).then((placemark) {
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
            address = "I am in emergency!\nThis is my current location: " +
                gatsby +
                "\nCoordinates: " +
                lat.toString() +
                "," +
                lng.toString();
            link = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
          });

          _center = LatLng(lat, lng);
          print("Lat: ${_center.latitude} and Lng: ${_center.longitude}");
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
                                initialCameraPosition:
                                    CameraPosition(target: _center, zoom: 11.5),
                                compassEnabled: true,
                                //markers:
                              ),
                            )),
                        Visibility(
                            visible: _isvisible,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            "Lat: ${_center.latitude} and Lng: ${_center.longitude}",
                            style: TextStyle(fontSize: 20),
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
                          child: Text("Level 1"),
                          onPressed: () {},
                        ),
                        RaisedButton(
                          child: Text("Level 2"),
                          onPressed: () {},
                        ),
                        RaisedButton(child: Text("Level 3"), onPressed: () {}),
                      ],
                    ),
                  ),
                ],
              ));
        });
    return _asyncLoader;
    /*SizedBox(height: 20,),
          CupertinoButton(
            // color: Color(0xff93E7AE),
              onPressed: () async {
                // widget._signOut();

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('Loggedin', false);
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text("Sign Out")),
        ],
      )
    );*/
  }
}
