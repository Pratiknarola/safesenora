import 'package:flutter/material.dart';
import 'package:safesenora/screens/first_screen.dart';
import 'package:safesenora/screens/intro.dart';
import 'package:safesenora/screens/setScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "safesenora",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("safesenora"),),
        body: setScreen(),
      )
    );
  }

}
