import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:prototype/util/getDrawer.dart';
import 'package:url_launcher/url_launcher.dart';


class protectorGirlScreen extends StatefulWidget {

  String girlid;
  String girlname;
  protectorGirlScreen(this.girlid, this.girlname);

  @override
  _protectorGirlScreenState createState() => _protectorGirlScreenState(girlid, girlname);
}

class _protectorGirlScreenState extends State<protectorGirlScreen> {
  GoogleMapController mapController;
  FirebaseUser currentUser;
  LatLng _center;
  double lat,
      lng;
  var location;
  bool _isTrafficEnabled = true;
  Set<Marker> _markers = {};
  String girlid;
  String girlname;

  _protectorGirlScreenState(this.girlid, this.girlname);

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user){
      currentUser = user;
    });
    print("in init state with lat $lat and $lng");
    print("this is marker");
    print(_markers);
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_center.toString()),
          position: _center,
          icon: BitmapDescriptor.defaultMarker));
      if (_markers.length > 1) {
        _markers.remove(_markers.elementAt(0));
      }
    });
  }
  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _center = LatLng(lat, lng);
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


  @override
  Widget build(BuildContext context) {

    print("this is marker");
    print(_markers);

    Widget loadprotectorgirlscreen(context, data){
      return Scaffold(
        drawer: getDrawer(currentUser, "protector").getdrawer(context),
        appBar: AppBar(title: Text("$girlname's tracking details"),),
        body: Container(
          color: Color(0xffbd5559),
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.6,
                child: GoogleMap(
                  //polylines: _polyline,
                  onMapCreated: _onMapCreated,
                  mapType: MapType.hybrid,
                  markers: _markers,
                  trafficEnabled: _isTrafficEnabled,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: _center == null ? LatLng(0, 0) : _center,
                      zoom: 11.5),
                  compassEnabled: true,
                  //markers:
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  CupertinoButton(
                    child: Text("Open in maps"),
                    onPressed: () {
                      openMap(lat, lng);
                    },
                  ),
                  CupertinoButton(
                    child: Text("Show marker"),
                    onPressed: () {
                      _onAddMarkerButtonPressed();
                    },
                  ),
                ],
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance.collection('girl_user')
                    .document(girlid)
                    .collection('user_info')
                    .document(girlid)
                    .snapshots(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Battery % -> ${snapshot.data["battery"]}"),
                  );
                }
              )

            ],
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('girl_user')
          .document(girlid)
          .collection('location_info')
          .document(girlid)
          .snapshots(),
      builder: (context, snapshot) {
        Future.delayed(Duration(seconds: 5));
        print(snapshot);
        print("that was snapshot");
        print("now will be data");
        print(snapshot.data);
        if (!snapshot.hasData)
          return LinearProgressIndicator();
        else {
          print(snapshot.data['last_location']);
          lat = snapshot.data["last_location"].latitude;
          print("latitude is $lat");
          lng = snapshot.data["last_location"].longitude;
          return loadprotectorgirlscreen(context, snapshot.data);
        }
      },
    );




  }
}


