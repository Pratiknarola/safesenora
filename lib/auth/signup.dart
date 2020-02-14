import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import '../screens/first_screen.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _userController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmController = new TextEditingController();

  bool _hidePassword = true;

  String _username, _password, _confirmPassword;

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
                      "Signup",
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
                    Card(
                      margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                      elevation: 11,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      child: TextFormField(
                        controller: _confirmController,
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          this._confirmPassword = _confirmController.text;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.black26,
                            ),
                            suffixIcon: (_password == _confirmController.text)
                                ? Icon(Icons.check)
                                : Icon(Icons.close),
                            hintText: "Confirm Password",
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
                            _signUp(context);
                          });
                        },
                        elevation: 11,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        child: Text(
                          "Signup",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                    ),
                    GestureDetector(
                      child: Text(
                        "Already have account? Login",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () => _login(context),
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

  _login(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<FirebaseUser> _signUp(context) async {
    try {
      FirebaseUser user = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _username, password: _password))
          .user;
      assert(user != null);
      assert(await user.getIdToken() != null);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => FirstScreen(user)));
    } catch (e) {
      print(e.message);
      return null;
    }
  }
}
