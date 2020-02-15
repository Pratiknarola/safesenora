import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:prototype/screens/pushNotificationTest.dart';
>>>>>>> 1e0917c855f6e397c2aa25ee654bbc556ca669b2
import 'package:prototype/screens/setScreen.dart';

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
          body: setScreen(),
        ));
  }
}
