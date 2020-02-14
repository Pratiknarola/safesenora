import 'package:flutter/material.dart';
import 'package:safesenora/auth/signup.dart';
import 'package:safesenora/screens/ProfilePage.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import './auth.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  Auth auth = Auth();
  TextEditingController _userController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  bool _hidePassword = true;

  String _username, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: 650,
            child: RotatedBox(
              quarterTurns: 2,
              child: WaveWidget(
                config: CustomConfig(
                  gradients: [
                    [Colors.pink, Colors.pink.shade200],
                    [
                      Colors.indigo.shade200,
                      Colors.purple.shade200
                    ], //TODO color change
                  ],
                  durations: [19440, 10800],
                  heightPercentages: [0.18, 0.25],
                  blur: MaskFilter.blur(BlurStyle.solid, 10),
                  gradientBegin: Alignment.bottomLeft,
                  gradientEnd: Alignment.topRight,
                ),
                waveAmplitude: 0,
                size: Size(double.infinity, double.infinity),
              ),
            ),
          ),
          ListView(
            children: <Widget>[
              Container(
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                      elevation: 11,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      child: TextFormField(
                        controller: _userController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.black26,
                            ),
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.black26),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16)),
                        onChanged: (value) {
                          _username = _userController.text;
                        },
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                      elevation: 11,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      child: TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          _password = _passwordController.text;
                        },
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.black26,
                            ),
                            suffixIcon: GestureDetector(
                              child: _hidePassword
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                              onTap: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                            ),
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.black26),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16)),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(30),
                      child: RaisedButton(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        color: Colors.lightBlue,
                        onPressed: () {
                          setState(() {
                            if (auth.signIn(_username, _password) != Null) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()));
                            } else {
                              print("wrong username or password");
                            }
                          });
                        },
                        elevation: 11,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Text(
                        "Forgot your password?",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () => _resetPassword(context),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                    ),
                    GestureDetector(
                      child: Text(
                        "New here? SignUp",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () => _signup(context),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

/*
  Future<void> _login(BuildContext context) async {
    try {
      FirebaseUser user = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: _username, password: _password))
          .user;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => FirstScreen(user)));
    } catch (e) {
      print(e.mesaage);
    }
  }
*/

  _resetPassword(BuildContext context) {}

  _signup(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => SignupPage()));
  }
}
