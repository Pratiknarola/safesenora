import 'package:flutter/material.dart';
import 'package:prototype/screens/pushNotificationTest.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Prototype",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text("Prototype"),
          ),
          body: pushNotification(),
        ));
  }
}
