import 'package:flutter/material.dart';
import './screens/first_screen.dart';
import './screens/intro.dart';
import './screens/setScreen.dart';

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
