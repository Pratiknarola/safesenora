import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/screens/ProfilePage.dart';
import 'package:prototype/screens/girl_home_screen.dart';
import 'package:prototype/screens/protector_home_screen.dart';
import 'package:prototype/screens/setScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  GlobalKey globalKey = GlobalKey<NavigatorState>();
  FirebaseUser firebaseUser;
  @override
  Widget build(BuildContext context) {
   
    FirebaseAuth.instance.currentUser().then((user) {
      firebaseUser = user;
    });
    
    return MaterialApp(
        navigatorKey: globalKey,
        routes: <String,WidgetBuilder>{
          "/girlhomepage":(BuildContext context)=> new girlHomeScreen(firebaseUser),
          "/protectorhomepage":(BuildContext context) => new protectorHomeScreen(firebaseUser),
          "/protectorgirlscreen":(BuildContext context)=> new protectorHomeScreen(firebaseUser),
        },
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
