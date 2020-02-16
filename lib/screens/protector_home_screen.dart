import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:prototype/screens/helping_girl_screen.dart';
import 'package:prototype/screens/trusted_girl_screen.dart';
import 'package:prototype/util/getDrawer.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received. $taskId');
  print("in line 19");
  try {
    geolocator.Position position = await geolocator.Geolocator()
        .getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.high);
    GeoPoint pos = GeoPoint(position.latitude, position.longitude);
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection("protector")
          .document(user.uid)
          .collection("location_info")
          .document(user.uid)
          .setData({"last_location": pos, "last_updated": DateTime.now()});
    });
  } catch (e) {
    try {
      geolocator.Position position = await geolocator.Geolocator()
          .getLastKnownPosition(

          desiredAccuracy: geolocator.LocationAccuracy.high);
      GeoPoint pos = GeoPoint(position.latitude, position.longitude);
      FirebaseAuth.instance.currentUser().then((user) {
        Firestore.instance
            .collection("protector")
            .document(user.uid)
            .collection("location_info")
            .document(user.uid)
            .setData({"last_location": pos, "last_updated": DateTime.now()});
      });
    } catch (e) {
      print(e);
    } finally {
      BackgroundFetch.finish(taskId);
    }
  }
}

class protectorHomeScreen extends StatefulWidget {
  FirebaseUser user;

  protectorHomeScreen(this.user);

  @override
  _protectorHomeScreenState createState() => _protectorHomeScreenState(user);
}

class _protectorHomeScreenState extends State<protectorHomeScreen>
    with SingleTickerProviderStateMixin {
  FirebaseUser user;
  String girluid;
  var count = 0;
  var selected;

  final int sendHeartbeatId = 0;

  _protectorHomeScreenState(this.user);

  String uid;
  var selectedItemId = 'Home';

  String _message = '';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _register() {
    _firebaseMessaging.getToken().then((token) => print(token));
  }



  Widget level1and3Notification(message) {
    return Center(
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(right: 16.0),
          height: 200,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(75),
                  bottomLeft: Radius.circular(75),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Row(
            children: <Widget>[
              SizedBox(width: 15.0),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                child: Image.network(
                  message['data']['image'],
                  width: 60,
                ),
              ),
              SizedBox(width: 15.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Alert!",
                      style: Theme.of(context).textTheme.title,
                    ),
                    SizedBox(height: 10.0),
                    Flexible(
                      child: Text(message['data']['title']),
                    ),
                    Flexible(
                      child: Text(message['data']['body']),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            child: Text("Got It"),
                            color: Colors.red,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Navigator.pop(context);

                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget level2Notification(message) {
    return Center(
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(right: 16.0),
          height: 200,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(75),
                  bottomLeft: Radius.circular(75),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Row(
            children: <Widget>[
              SizedBox(width: 15.0),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                child: Image.network(
                  message['data']['image'],
                  width: 60,
                ),
              ),
              SizedBox(width: 15.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Alert!",
                      style: Theme.of(context).textTheme.title,
                    ),
                    SizedBox(height: 10.0),
                    Flexible(
                      child: Text(message['data']['title']),
                    ),
                    Flexible(
                      child: Text(message['data']['body']),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            child: Text("No"),
                            color: Colors.red,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Firestore.instance
                                  .collection('girl_user')
                                  .document(message['data']['girl_id'])
                                  .collection('help_permission')
                                  .document(user.uid)
                                  .setData({'permission': false}, merge: true);
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: RaisedButton(
                            child: Text("Yes"),
                            color: Colors.green,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Firestore.instance
                                  .collection('girl_user')
                                  .document(message['data']['girl_id'])
                                  .collection('help_permission')
                                  .document(user.uid)
                                  .setData({'permission': true}, merge: true);
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getMessage() {
    _firebaseMessaging.configure(

        // ignore: missing_return
        onMessage: (Map<String, dynamic> message) {
      var level1 = message['data']['level1'];

      var level2 = message['data']['level2'];
      var level3 = message['data']['level3'];
      var pressedLevel = message['data']['pressedLevel'];
      var batteryLevel = message['data']['battery'];
      var girluserid = message['data']['girl_id'];
      print('pressed level $pressedLevel and level1 is $level1');
      if (pressedLevel == 'level1' && level1 == 'true' && count == 0) {
        print("on message $message");
        print("current count is $count");
        count += 1;
        showDialog(
            context: context,
            builder: (context) {
              return level1and3Notification(message);
              //TODO setstate to show changes according to levels and data
            });
      } else if (pressedLevel == 'level2' && level2 == 'true' && count == 0) {
        print("on message $message");
        print("current count of level2 mesej is $count");
        showDialog(
            context: context,
            builder: (context) {
              return level2Notification(message);
              //TODO setstate to show changes according to levels and data
            });
      } else if (pressedLevel == 'level3' && level3 == 'true' && count == 0) {
        print("on message $message");
        print("current count of level2 mesej is $count");
        showDialog(
            context: context,
            builder: (context) {
              return level1and3Notification(message);
              //TODO setstate to show changes according to levels and data
            });
      }
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume hello in resumed state $message');
      var level1 = message['data']['level1'];
      var level2 = message['data']['level2'];
      var level3 = message['data']['level3'];
      var pressedLevel = message['data']['pressedLevel'];
      var batteryLevel = message['data']['battery'];
      var girluserid = message['data']['girl_id'];
      print('pressed level $pressedLevel and level1 is $level1');
      if (pressedLevel == 'level1' && level1 == 'true' && count == 0) {
        print("on message $message");
        print("current count is $count");
        count += 1;
        showDialog(
            context: context,
            builder: (context) {
              return level1and3Notification(message);
              //TODO setstate to show changes according to levels and data
            });
      } else if (pressedLevel == 'level2' && level2 == 'true' && count == 0) {
        print("on message $message");
        print("current count of level2 mesej is $count");
        showDialog(
            context: context,
            builder: (context) {
              return level2Notification(message);
              //TODO setstate to show changes according to levels and data
            });
      } else if (pressedLevel == 'level3' && level3 == 'true' && count == 0) {
        print("on message $message");
        print("current count of level2 mesej is $count");
        showDialog(
            context: context,
            builder: (context) {
              return level1and3Notification(message);
              //TODO setstate to show changes according to levels and data
            });
      }

      print("resume");
      print("resume");
      print("resume");

      print('on resume hello in resumed state $message');
      setState(() => _message = "hello on resume ${message["data"]["title"]}");
    }, onLaunch: (Map<String, dynamic> message) async {
      var level1 = message['data']['level1'];
      var level2 = message['data']['level2'];
      var level3 = message['data']['level3'];
      var pressedLevel = message['data']['pressedLevel'];
      var batteryLevel = message['data']['battery'];
      var girluserid = message['data']['girl_id'];
      print('pressed level $pressedLevel and level1 is $level1');
      if (pressedLevel == 'level1' && level1 == 'true' && count == 0) {
        print("on message $message");
        print("current count is $count");
        count += 1;
        showDialog(
            context: context,
            builder: (context) {
              return level1and3Notification(message);
              //TODO setstate to show changes according to levels and data
            });
      } else if (pressedLevel == 'level2' && level2 == 'true' && count == 0) {
        print("on message $message");
        print("current count of level2 mesej is $count");
        showDialog(
            context: context,
            builder: (context) {
              return level2Notification(message);
              //TODO setstate to show changes according to levels and data
            });
      } else if (pressedLevel == 'level3' && level3 == 'true' && count == 0) {
        print("on message $message");
        print("current count of level2 mesej is $count");
        showDialog(
            context: context,
            builder: (context) {
              return level1and3Notification(message);
              //TODO setstate to show changes according to levels and data
            });
      }
      print('on launch on aunched state $message');
      print("launch");
      print("launch");
      print("launch");
      print("launch");

      print('on launch on aunched state $message');
    });
  }

  @override
  void initState() {
    selected = 'girl_list';
    initAlarm();
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    super.initState();
    uid = user.uid;
    initBackgroundfetch();
    getMessage();

    /*var location = Location();
    location.changeSettings(
        accuracy: LocationAccuracy.HIGH);
    location.requestPermission().then((granted) {
      if (granted) {
        location.onLocationChanged().listen((locationData) {
          if (locationData != null) {
            double lat = locationData.latitude;
            double lng = locationData.longitude;
            print("got location data $lat and $lng");
            Firestore.instance
                .collection("protector")
                .document(uid)
                .collection("location_info")
                .document(uid)
                .setData({"last_location": GeoPoint(lat, lng)});
            Future.delayed(Duration(minutes: 10));
          }
        });
      }

      print('calling get message in inint state');
      print('got out of mesej with count $count');
    });*/
  }

  final TextStyle dropdownMenuItem =
  TextStyle(color: Colors.black, fontSize: 18);

  final primary = Color(0xff696b9e);
  final secondary = Color(0xfff29a94);

  void _onClickEnable(enabled) {
    /*setState(() {
    _enabled = enabled;
  });*/
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    /*setState(() {
    _status = status;
  });*/
  }

  void sendHeartbeat(){
    print("into send heartbeat");
    const platform = const MethodChannel("platformlocation");
    platform.invokeMethod("sendBroadcast");
    print("Method invoked");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('protector')
          .document(user.uid)
          .collection('girl_list')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();
        else {
          return buildHomepageList(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget buildHomepageList(context, girl_docs) {
    return Scaffold(
      backgroundColor: Color(0xfff0f0f0),
      drawer: getDrawer(user, 'protector').getdrawer(context),
      appBar: AppBar(
        title: Text(''),
        backgroundColor: primary,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  child: Center(
                    child: Text(
                      "Helping Girl's",
                      style: TextStyle(
                          color: selected == 'helping_list'
                              ? secondary
                              : Colors.white,
                          fontSize: 20),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selected = 'helping_list';
                    });
                  },
                ),
                VerticalDivider(
                  color: Colors.white,
                  indent: 18,
                  thickness: 1,
                  endIndent: 13,
                ),
                GestureDetector(
                  child: Center(
                    child: Text(
                      "Trusted Girls's",
                      style: TextStyle(
                          color:
                              selected == 'girl_list' ? secondary : Colors.white,
                          fontSize: 20),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selected = 'girl_list';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
              child: girlList()),
        ],
      ),
    );
  }


  Widget girlList() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('protector')
          .document(user.uid)
          .collection(selected)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();
        else {
          return buildHomepageGirlList(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget buildHomepageGirlList(context, girl_docs) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: ListView.builder(
                  itemCount: girl_docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildList(context, index, girl_docs);
                  }),
            ),
          ),
          /*Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Girl's List",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),*/
          /*Container(
            child: Column(
              children: <Widget>[
                 RaisedButton(
                  child: Text(
                    "Start serive",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  onPressed: () => _onClickEnable(true),
                ),
                RaisedButton(
                  child: Text(
                    "Stop serive",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  onPressed: () => _onClickEnable(false),
                ),
              ],
            ),
          )*/
        ],
      ),
    );
  }

  Widget buildList(BuildContext context, int index, girl_docs) {
    String girl_uid = girl_docs[index].documentID;
    girl_uid = girl_uid.trimLeft();
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('girl_user')
            .document(girl_uid)
            .collection('user_info')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return LinearProgressIndicator();
          else
            return buildSingleList(snapshot.data.documents[0], girl_uid);
        });
  }

  Widget buildSingleList(snapshot, girl_uid) {
    Firestore.instance
        .collection('protector')
        .document(user.uid)
        .collection(selected)
        .document(girl_uid)
        .setData({
      'battery': snapshot['battery'],
      'name': snapshot['name'],
      'surname': snapshot['surname'],
      'picture': snapshot['picture']
    }, merge: true);

    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>  selected == 'girl_list'
                      ? trustedGirlScreen(girl_uid, snapshot):
                  helpingGirlScreen(girl_uid, snapshot)));

        },
        child: Container(
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
                                color: primary,
                                fontSize: 13,
                                letterSpacing: .3)),
                      ],
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.battery_charging_full,
                          color: secondary,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(snapshot['battery'],
                            style: TextStyle(
                                color: primary,
                                fontSize: 13,
                                letterSpacing: .3)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Future<void> initBackgroundfetch() async {
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "flutter_background_fetch",
        periodic: true,
        delay: 5000,
        startOnBoot: true,
        stopOnTerminate: false,
        enableHeadless: true,
        forceAlarmManager: true,
        requiredNetworkType: NetworkType.ANY,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false
    ));

    BackgroundFetch.configure(
        BackgroundFetchConfig(
            startOnBoot: true,
            minimumFetchInterval: 15,
            forceAlarmManager: true,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY), (String taskId) async {
      // This is the fetch-event callback.
      print("[BackgroundFetch] Event received $taskId");
      try {
        geolocator.Position position = await geolocator.Geolocator()
            .getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.high);
        GeoPoint pos = GeoPoint(position.latitude, position.longitude);
        Firestore.instance
            .collection("protector")
            .document(uid)
            .collection("location_info")
            .document(uid)
            .setData({"last_location": pos, "last_updated": DateTime.now()});
      } catch (e) {
        try {
          geolocator.Position position = await geolocator.Geolocator()
              .getLastKnownPosition(
              desiredAccuracy: geolocator.LocationAccuracy.high);
          GeoPoint pos = GeoPoint(position.latitude, position.longitude);
          Firestore.instance
              .collection("protector")
              .document(uid)
              .collection("location_info")
              .document(uid)
              .setData({"last_location": pos, "last_updated": DateTime.now()});
        } catch (e) {
          print(e);
        } finally {
          print("[Background Fetch] finishing the task $taskId");
          BackgroundFetch.finish(taskId);
        }

        /*BackgroundFetch.scheduleTask(TaskConfig(
            //taskId: '',
            delay: 5000,       // milliseconds
            forceAlarmManager: true,
            periodic: true
        ));*/
        /*setState(() {
        //_events.insert(0, new DateTime.now());
      });*/
        // IMPORTANT:  You must signal completion of your task or the OS can punish your app
        // for taking too long in the background.

      }
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
      /* setState(() {
        _status = status;
      });*/
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      /*setState(() {
        _status = e;
      });*/
    });

// Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    print("Background fetch status is $status");
    /*setState(() {
      _status = status;
    });*/

// If the widget was removed from the tree while the asynchronous platform
// message was in flight, we want to discard the reply rather than calling
// setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void initAlarm() async{
    print("in init alarm");
    await AndroidAlarmManager.initialize();
    print("androidAlarmManager initialize");
    await AndroidAlarmManager.periodic(const Duration(minutes: 5), sendHeartbeatId, sendHeartbeat);
    print("periodic event registered");
  }
}
