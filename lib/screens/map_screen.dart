import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_plugin;
import 'package:prototype/screens/girl_home_screen.dart';

class girlMapScreen extends StatefulWidget {

  @override
  _girlMapScreenState createState() => _girlMapScreenState();
}

class _girlMapScreenState extends State<girlMapScreen>{
  double lat, lng;
  static LatLng _center;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  LatLng _lastmapposition = _center;
  location_plugin.Location location;
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    location.getLocation().then((loc){
      _center = LatLng(loc.latitude, loc.longitude);
    });
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastmapposition.toString()),
          position: _lastmapposition,
          icon: BitmapDescriptor.defaultMarker));

    });
  }

  LocationServices() {
    location.getLocation().then((loc){
      lat = loc.latitude;
      lng = loc.longitude;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("View Map"),),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.50,
                width: MediaQuery.of(context).size.width * 0.80,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(12.0)
                ),
                child: GoogleMap(
                  onMapCreated:_onMapCreated,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: _center == null ? LatLng(0, 0) : _center, zoom: 12),
                  compassEnabled: true,
                ),
              ),
              Container(
                padding: new EdgeInsets.all(30.0),
                height: MediaQuery.of(context).size.height * 0.30,
                //width: MediaQuery.of(context).size.width * 0.20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RaisedButton(
                      child: Text("Marker",
                          style: TextStyle(color: Colors.black,
                              fontSize: 12,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w400
                          ),
                          textAlign: TextAlign.center,
                          textScaleFactor: 2.0),
                      onPressed: _onAddMarkerButtonPressed,
                    ),
                    /* SizedBox(
                      width: 40,
                    ),*/
                    RaisedButton(
                        child: Text("Reload",
                            style: TextStyle(color: Colors.black,
                                fontSize: 12,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w400
                            ),
                            textAlign: TextAlign.center,
                            textScaleFactor: 2.0),
                        onPressed: () {
                          setState(() {
                            if (lat != null && lng != null) {
                              _center = LatLng(lat, lng);
                            } else {
                              LocationServices();
                            }
                          });
                        })
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}