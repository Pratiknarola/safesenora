import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class trustedGirlScreen extends StatefulWidget {
  String girlid;
  var girl_docsnap;

  trustedGirlScreen(this.girlid, this.girl_docsnap);

  @override
  _trustedGirlScreenState createState() =>
      _trustedGirlScreenState(girlid, girl_docsnap);
}

class _trustedGirlScreenState extends State<trustedGirlScreen> {
  GoogleMapController mapController;
  FirebaseUser currentUser;
  LatLng _center;
  double lat, lng;
  var location;
  bool _isTrafficEnabled = true;
  Set<Marker> _markers = {};
  String girlid;
  var girl_docsnap;
  var allowed;
  var selected = 'girlLocation';

  final secondary = Color(0xff696b9e);
  final primary = Color(0xfff29a94);

  _trustedGirlScreenState(this.girlid, this.girl_docsnap);

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
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
    return Scaffold(
      /* drawer: getDrawer(currentUser, "protector").getdrawer(context),
        appBar: AppBar(title: Text("$girlname's tracking details"),),*/
      appBar: AppBar(
        title: Text(''),
        backgroundColor: primary,
        elevation: 0,
      ),
      backgroundColor: Color(0xfff0f0f0),
      body: Column(
        children: <Widget>[
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  child: Center(
                    child: Text(
                      "Girl Live Location",
                      style: TextStyle(
                          color: selected == 'girlLocation'
                              ? secondary
                              : Colors.white,
                          fontSize: 20),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selected = 'girlLocation';
                    });
                  },
                ),
                VerticalDivider(
                  color: Colors.white,
                  indent: 9,
                  thickness: 1,
                  endIndent: 8,
                ),
                GestureDetector(
                  child: Center(
                    child: Text(
                      "Nearby Users",
                      style: TextStyle(
                          color: selected == 'nearbyUser'
                              ? secondary
                              : Colors.white,
                          fontSize: 20),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selected = 'nearbyUser';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
              child: selected == 'girlLocation'
                  ? girlLiveLocationPage()
                  : nearbyUser()),
        ],
      ),
    );
  }

  Widget nearbyUser() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('girl_user')
          .document(girlid)
          .collection('agreed_user')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();
        else {
          return buildnearbyUserList(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget buildnearbyUserList(context, agreeduser_docs) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              width: double.infinity,
              child: ListView.builder(
                  itemCount: agreeduser_docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildnearbyList(context, index, agreeduser_docs);
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildnearbyList(context, index, agreeduser_docs) {
    String agreeduser_id = agreeduser_docs[index].documentID;
    allowed = agreeduser_docs[index]['allowed'];
    agreeduser_id = agreeduser_id.trimLeft();
    print('user iddddis$agreeduser_id');
    print(agreeduser_id);
    print(agreeduser_id.length);
    print("xyz$agreeduser_id");
    /*Firestore.instance
        .collection('protector')
        .document('Z1ptQBCgabdJcx0pO2vrHaTKWt72')
        .collection('user_info')
        .document('Z1ptQBCgabdJcx0pO2vrHaTKWt72')
        .get()
        .then((snap) {
      print('hello');
      print('name is ${snap['name']}');
    });*/
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('protector')
            .document(agreeduser_id)
            .collection('user_info')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return LinearProgressIndicator();
          else
            return buildSingleList(snapshot.data.documents[0], agreeduser_id,
                agreeduser_docs[index]['allowed']);
        });
  }

  Widget buildSingleList(snapshot, agreeduser_id, index_allowed) {
    print('aggggreeiid id is$agreeduser_id  and is $index_allowed');
    print('name is ${snapshot['name']}');
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
      ),
      width: double.infinity,
      height: 110,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(width: 3, color: secondary)),
            child: Image.network(
              snapshot['picture'],
              width: 50,
              height: 50,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${snapshot['name']} ${snapshot['surname']}',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                SizedBox(
                  height: 6,
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.phone,
                      color: secondary,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(snapshot['phone'],
                        style: TextStyle(
                            color: primary, fontSize: 13, letterSpacing: .3)),
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                index_allowed == 'NA'
                    ? Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          child: Text("Dont Allow"),
                          color: Colors.red,
                          colorBrightness: Brightness.dark,
                          onPressed: () {
                            print(
                                'hello in sett statee$agreeduser_id ${agreeduser_id
                                    .length} girl id $girlid');
                            Firestore.instance
                                .collection('girl_user')
                                .document(girlid)
                                .collection('agreed_user')
                                .document(agreeduser_id)
                                .setData({'allowed': 'Not Allowed'},
                                merge: true);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: RaisedButton(
                          child: Text("Allow"),
                          color: Colors.green,
                          colorBrightness: Brightness.dark,
                          onPressed: () {
                            print('allow pressed');
                            Firestore.instance
                                .collection('girl_user')
                                .document(girlid)
                                .collection('allowed_user')
                                .document(agreeduser_id)
                                .setData({
                              'name': snapshot['name'],
                              'surname': snapshot['surname'],
                              'phone': snapshot['phone'],
                              'picture': snapshot['picture'],
                              'battery': snapshot['battery'],
                              'birth': snapshot['birth'],
                            }, merge: true);
                            Firestore.instance
                                .collection('protector')
                                .document(agreeduser_id)
                                .collection('helping_list')
                                .document(girlid)
                                .setData({
                              'girl_id': girlid,
                            }, merge: true);
                            Firestore.instance
                                .collection('girl_user')
                                .document(girlid)
                                .collection('agreed_user')
                                .document(agreeduser_id)
                                .setData({'allowed': 'Allowed'},
                                merge: true);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                      ),
                    ],
                  ),
                )
                    : Expanded(
                  child: RaisedButton(
                    child: Text(index_allowed),
                    color: Colors.transparent,
                    colorBrightness: Brightness.dark,
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /* void deleteFromAgreedList(girlid, proid) {
    Firestore.instance
        .collection('girl_user')
        .document('$girlid')
        .collection('agreed_user')
        .document(proid)
        .delete();
  }*/

  Widget girlLiveLocationPage() {
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
                  target: _center == null ? Location().getLocation().then((loc) {return LatLng(loc.latitude, loc.longitude);}) : _center, zoom: 11.5),
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
              })
        ],
      ),
    );
  }
}
/*    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('girl_user')
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
  }*/
