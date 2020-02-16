import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class helpingGirlScreen extends StatefulWidget {
  String girlid;
  var girl_docsnap;
  helpingGirlScreen(this.girlid, this.girl_docsnap);

  @override
  _helpingGirlScreenState createState() =>
      _helpingGirlScreenState(girlid, girl_docsnap);
}

class _helpingGirlScreenState extends State<helpingGirlScreen> {
  String girlid;
  var girl_docsnap;

  GoogleMapController mapController;
  FirebaseUser currentUser;
  LatLng _center;
  double lat, lng;
  var location;
  bool _isTrafficEnabled = true;
  Set<Marker> _markers = {};

  _helpingGirlScreenState(girlid, girl_docsnap);

  void _onAddMarkerButtonPressed() {
    _markers.add(Marker(
        markerId: MarkerId(_center.toString()),
        position: _center,
        icon: BitmapDescriptor.defaultMarker));
    if (_markers.length > 1) {
      _markers.remove(_markers.elementAt(0));
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _center = LatLng(0, 0);
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
    // TODO: implement build
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('girl_user')
          .document(girlid)
          .collection('location_info')
          .document(girlid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          print('i have got data ${snapshot.data['last_location'].latitude}');
          var lat = snapshot.data['last_location'].latitude;
          var lng = snapshot.data['last_location'].longitude;
          _center = LatLng(lat, lng);
          _onAddMarkerButtonPressed();

          return Container(
            color: Color(0xfff0f0f0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15))),
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    markers: _markers,
                    initialCameraPosition:
                    CameraPosition(target: LatLng(lat, lng), zoom: 15),
                    compassEnabled: true,
                  ),
                ),
                Expanded(
                  child: Row(
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
                ),

                /*Expanded(
            child: StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('girl_user')
                    .document(girlid)
                    .collection('user_info')
                    .document(girlid)
                    .snapshots(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Battery % -> ${snapshot.data["battery"]}"),
                  );
                }),
          ),*/
              ],
            ),
          );

          /*
          return callsetState(context);*/
        }
      },
    );
  }
}
