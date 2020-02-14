import 'package:flutter/material.dart';
import './screens/setScreen.dart';

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
