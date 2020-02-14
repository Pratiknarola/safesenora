import 'package:flutter/material.dart';
import 'package:safesenora/first_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "Prototype",
      debugShowCheckedModeBanner: false,
      home: FirstScreen(),
    );
  }

}
