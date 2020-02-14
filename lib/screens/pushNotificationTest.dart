import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class pushNotification extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return pushNotificationState();
  }
}

class pushNotificationState extends State<pushNotification> {
  String _message = '';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _register() {
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessage();
  }

  void getMessage() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: ListTile(
                  title: Text(message['notification']['title']),
                  subtitle: Text(message['notification']['body']),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("heya"),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
      setState(() {
        print('hello inside setstate');
        _message =
            _message = "hello on message ${message["notification"]["title"]}";
      });
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume hello in resumed state $message');
      setState(() =>
          _message = "hello on resume ${message["notification"]["title"]}");
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch on aunched state $message');
      setState(() => _message = message["notification"]["title"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("the message as $_message");
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Messagerrrrrr: $_message"),
                OutlineButton(
                  child: Text("Register My Device"),
                  onPressed: () {
                    _register();
                  },
                ),
                // Text("Message: $message")
              ]),
        ),
      ),
    );
  }
}
