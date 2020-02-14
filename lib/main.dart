import 'package:flutter/material.dart';
import 'package:prototype/screens/first_screen.dart';
import 'package:prototype/screens/intro.dart';
import 'package:prototype/screens/setScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "Prototype",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Prototype"),),
        body: setScreen(),
      )
    );
  }

}
