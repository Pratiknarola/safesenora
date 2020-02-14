import 'package:flutter/material.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Prototype")),
      body: Container(
        child: Center(
          child: Text("This is first screen", style: TextStyle(
              backgroundColor: Colors.white,
              fontSize: 14.0,
              color: Colors.black
          ),),
        ),
      ),
    );
  }
}

