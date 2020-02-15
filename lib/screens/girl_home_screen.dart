import 'dart:async';
import 'dart:math';

import 'package:async_loader/async_loader.dart';
import 'package:backdrop/backdrop.dart';
import 'package:battery/battery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_plugin;
import 'package:sms_maintained/sms.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

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
  String uid;
  var selectedItemId = 'Home';

  bool _isvisible = false;
  bool level_1_pressed = false;
  bool level_2_pressed = false;
  bool level_3_pressed = false;

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
    WidgetsBinding.instance.addObserver(this);
    super.initState();

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

    /*************java location testing*****************/
    const platform = const MethodChannel("platformlocation");
    print("java location testing");
    print("channel created");
    try {
      () async {
        print("calling letlastlocation");
        print(platform);
        //await platform.invokeMethod("startLocationService");
        print("location call done");
      }();
    } catch (e) {
      print("error in java lastlocation");
      print(e);
    }

    /*****************Battery part *******************/
    battery = Battery();
    () async {
      pastBatteryLevel = await battery.batteryLevel;
      print('in init state with battery $pastBatteryLevel');
    }();

    battery.onBatteryStateChanged.listen((BatteryState state) async {
      var currentBatteryLevel = await battery.batteryLevel;
      if (currentBatteryLevel >= 50 &&
          (pastBatteryLevel - currentBatteryLevel > 1)) {
        pastBatteryLevel = currentBatteryLevel;
        Firestore.instance
            .collection('girl_user')
            .document(user.uid)
            .collection('user_info')
            .document(user.uid)
            .setData({'battery': '$currentBatteryLevel'}, merge: true);
      } else if (currentBatteryLevel < 50) {
        pastBatteryLevel = currentBatteryLevel;
        Firestore.instance
            .collection('girl_user')
            .document(user.uid)
            .collection('user_info')
            .document(user.uid)
            .setData({'battery': '$currentBatteryLevel'}, merge: true);
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
            /*Firestore.instance
                .collection("locations")
                .add({"lat": lat, "long": lng});*/
            if (_center == null) {
              _center = LatLng(lat, lng);
            }
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
                  /*address =
                      "I am in emergency!\nThis is my current location: " +
                          gatsby +
                          "\nCoordinates: " +
                          lat.toString() +
                          "," +
                          lng.toString();*/
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
            Firestore.instance
                .collection("locations")
                .add({"lat": lat, "long": lng});
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
    LocationServices();
    location.onLocationChanged().listen((locationData) {
      if (locationData != null) {
        lat = locationData.latitude;
        lng = locationData.longitude;
        print(lat);
        print(lng);
        print("lat and lng");
        Firestore.instance
            .collection("locations")
            .add({"lat": lat, "long": lng});
      }
    });
    battery.onBatteryStateChanged.listen((BatteryState state) async {
      var currentBatteryLevel = await battery.batteryLevel;
      if (currentBatteryLevel >= 50 &&
          (pastBatteryLevel - currentBatteryLevel > 2)) {
        pastBatteryLevel = currentBatteryLevel;
        Firestore.instance
            .collection('girl_user')
            .document(user.uid)
            .collection('user_info')
            .document(user.uid)
            .setData({'battery': '$currentBatteryLevel'}, merge: true);
      } else if (currentBatteryLevel < 50) {
        pastBatteryLevel = currentBatteryLevel;
        Firestore.instance
            .collection('girl_user')
            .document(user.uid)
            .collection('user_info')
            .document(user.uid)
            .setData({'battery': '$currentBatteryLevel'}, merge: true);
      }
    });

//akg19082000#
    //_center = LatLng(lat, lng);
    //print("Lat: ${_center.latitude} and Lng: ${_center.longitude}");

    return BackdropScaffold(
        //appBar: _buildBar(context),
        title: Text(
          "Home Screen",
          textAlign: TextAlign.center,
        ),
        iconPosition: BackdropIconPosition.action,
        frontLayer: Column(
          //scrollDirection: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                  child: new FittedBox(
                child: Material(
                  color: Colors.white,
                  elevation: 14.0,
                  borderRadius: BorderRadius.circular(24.0),
                  shadowColor: Color(0x802196F3),
                  child: Visibility(
                    visible: !level_1_pressed,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: RaisedButton(
                        onPressed: () {
                          Firestore.instance
                              .collection('girl_user')
                              .document(user.uid)
                              .collection('level_info')
                              .document(user.uid)
                              .setData({'level1': true}, merge: true);
                          setState(() {
                            //level_1_pressed = true;
                            level_1_pressed = !level_1_pressed;
                          });
                        },
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Text(
                                "Level 1",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            WaveWidget(
                              config: CustomConfig(
                                gradients: [
                                  [Colors.yellow, Color(0x55FFEB3B)],
                                  [Colors.red, Color(0xEEF44336)]
                                ],
                                durations: [10800, 6000],
                                heightPercentages: [0.40, 0.30],
                                blur: MaskFilter.blur(BlurStyle.inner, 10),
                                gradientBegin: Alignment.bottomLeft,
                                gradientEnd: Alignment.topRight,
                              ),
                              waveAmplitude: 8,
                              backgroundColor: Colors.amber[50],
                              size: Size(double.infinity, double.infinity),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: new FittedBox(
                  child: Material(
                    color: Colors.white,
                    elevation: 14.0,
                    borderRadius: BorderRadius.circular(24.0),
                    shadowColor: Color(0x802196F3),
                    child: Container(
                      height: 400,
                      child: Visibility(
                        visible: !level_2_pressed,
                        child: RaisedButton(
                          onPressed: () {
                            Firestore.instance
                                .collection('girl_user')
                                .document(user.uid)
                                .collection('level_info')
                                .document(user.uid)
                                .setData({'level2': true}, merge: true);
                            setState(() {
                              //level_1_pressed = true;
                              //level_2_pressed = !level_2_pressed;
                            });
                          },
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "Level 2",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              WaveWidget(
                                config: CustomConfig(
                                  gradients: [
                                    [Colors.yellow, Color(0x55FFEB3B)],
                                    [Colors.red, Color(0xEEF44336)]
                                  ],
                                  durations: [10800, 6000],
                                  heightPercentages: [0.40, 0.30],
                                  blur: MaskFilter.blur(BlurStyle.inner, 10),
                                  gradientBegin: Alignment.bottomLeft,
                                  gradientEnd: Alignment.topRight,
                                ),
                                waveAmplitude: 8,
                                backgroundColor: Colors.amber[50],
                                size: Size(double.infinity, double.infinity),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: new FittedBox(
                  child: Material(
                    color: Colors.white,
                    elevation: 14.0,
                    borderRadius: BorderRadius.circular(24.0),
                    shadowColor: Color(0x802196F3),
                    child: Visibility(
                      visible: !level_3_pressed,
                      child: Container(
                        height: 400,
                        child: RaisedButton(
                          onPressed: () {
                            Firestore.instance
                                .collection('girl_user')
                                .document(user.uid)
                                .collection('level_info')
                                .document(user.uid)
                                .setData({'level3': true}, merge: true);
                            //*setState(() {
                            //level_3_pressed = ! level_3_pressed;
                          },
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "Level 3",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              WaveWidget(
                                config: CustomConfig(
                                  gradients: [
                                    [Colors.yellow, Color(0x55FFEB3B)],
                                    [Colors.red, Color(0xEEF44336)]
                                  ],
                                  durations: [10800, 6000],
                                  heightPercentages: [0.40, 0.30],
                                  blur: MaskFilter.blur(BlurStyle.inner, 10),
                                  gradientBegin: Alignment.bottomLeft,
                                  gradientEnd: Alignment.topRight,
                                ),
                                waveAmplitude: 8,
                                backgroundColor: Colors.amber[50],
                                size: Size(double.infinity, double.infinity),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        backLayer: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.50,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                //polylines: _polyline,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                //myLocationButtonEnabled: true,
                initialCameraPosition: CameraPosition(
                    target: _center == null ? LatLng(0, 0) : _center, zoom: 12),
                compassEnabled: true,
              ),
            ),
            Container(
              padding: new EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Material(
                    color: Colors.white,
                    elevation: 14.0,
                    child: RaisedButton(
                      child: Text("Add Marker"),
                      onPressed: _onAddMarkerButtonPressed,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  RaisedButton(
                    child: Text("Reload"),
                    onPressed: () {
                      setState(() {
                        if (lat != null && lng != null) {
                          _center = LatLng(lat, lng);
                        } else {
                          LocationServices();
                        }
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ));
  }
/*return Scaffold(
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
                  onPressed: () {
                    setState(() {
                      if (lat != null && lng != null) {
                        _center = LatLng(lat, lng);
                      } else {
                        LocationServices();
                      }
                    });
                  },
                ),
                RaisedButton(
                  child: Text("Reset Levels"),
                  onPressed: () {
                    Firestore.instance
                        .collection('girl_user')
                        .document(user.uid)
                        .collection('level_info')
                        .document(user.uid)
                        .setData(
                            {'level1': false, 'level2': false, 'level3': false},
                            merge: true);
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
                    String mesej =
                        '${userData['name']} ${userData['surname']} has pressed level1.He/She may get in danger so please keep phone near you.Track his/her location details by opening the app.';
                    send_sms(mesej);
                    setState(() {});
                  },
                ),
                RaisedButton(
                  child: Text("Level 2"),
                  onPressed: () {
                    print('pppppppppressssssssseddddddddddd level222222222');
                    Firestore.instance
                        .collection('girl_user')
                        .document(user.uid)
                        .collection('level_info')
                        .document(user.uid)
                        .setData({'level2': true}, merge: true);
                    String meseej =
                        '${userData['name']} ${userData['surname']} has pressed level2.If u want the people around your girl to help her,please open prototype app and give us permissions.';
                    send_sms(meseej);

                    print('mesej of levvvvellll 2 ssssseeeeeeeeeeenttttttttt');

                    setState(() {});
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
                      String mesej =
                          '${userData['name']} ${userData['surname']} has pressed level3.Please you go and help her asap, inform the police if u want.Track his location by opening the app.';
                      send_sms(mesej);

                      setState(() {});
                    }),
              ],
            ),
          ),
        ],
      ),
    );
    */

}
