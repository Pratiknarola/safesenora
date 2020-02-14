import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';
import 'package:prototype/auth/setUserRole.dart';
import 'package:prototype/screens/girl_home_screen.dart';
import 'package:prototype/screens/protector_home_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'countdown_base.dart';
import 'firebase_listenter.dart';
import 'firebase_phone_util.dart';
import 'progresshud.dart';

class OtpVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OtpVerificationScreenState(),
    );
  }
}

class OtpVerificationScreenState extends StatefulWidget {
  @override
  _OtpVerificationScreenState createState() =>
      new _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreenState>
    implements FirebaseAuthListener {
  bool _isLoading = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String otpWaitTimeLabel = "";
  bool _isMobileNumberEnter = false;

  final _teOtpDigitOne = TextEditingController();
  final _teOtpDigitTwo = TextEditingController();
  final _teOtpDigitThree = TextEditingController();
  final _teOtpDigitFour = TextEditingController();
  final _teOtpDigitFive = TextEditingController();
  final _teOtpDigitSix = TextEditingController();

  FocusNode _focusNodeDigitOne = new FocusNode();
  FocusNode _focusNodeDigitTwo = new FocusNode();
  FocusNode _focusNodeDigitThree = new FocusNode();
  FocusNode _focusNodeDigitFour = new FocusNode();
  FocusNode _focusNodeDigitFive = new FocusNode();
  FocusNode _focusNodeDigitSix = new FocusNode();

  FirebasePhoneUtil presenter;

  static const TextStyle linkStyle = const TextStyle(
    color: const Color(0xFF8C919E),
    fontWeight: FontWeight.bold,
  );

  /* @override
  void dispose() {
    super.dispose();
    _teOtpDigitOne.dispose();
  }*/

  @override
  void initState() {
    super.initState();
    presenter = FirebasePhoneUtil();
    presenter.setScreenListener(this);
    changeFocusListener(_teOtpDigitOne, _focusNodeDigitTwo);
    changeFocusListener(_teOtpDigitTwo, _focusNodeDigitThree);
    changeFocusListener(_teOtpDigitThree, _focusNodeDigitFour);
    changeFocusListener(_teOtpDigitFour, _focusNodeDigitFive);
    changeFocusListener(_teOtpDigitFive, _focusNodeDigitSix);

    checkFiled(_teOtpDigitOne);
    checkFiled(_teOtpDigitTwo);
    checkFiled(_teOtpDigitThree);
    checkFiled(_teOtpDigitFour);
    checkFiled(_teOtpDigitFive);
    checkFiled(_teOtpDigitSix);
    startTimer();
  }

  void checkFiled(TextEditingController teController) {
    teController.addListener(() {
      if (!_teOtpDigitOne.text.isEmpty &&
          !_teOtpDigitTwo.text.isEmpty &&
          !_teOtpDigitThree.text.isEmpty &&
          !_teOtpDigitFour.text.isEmpty &&
          !_teOtpDigitFive.text.isEmpty &&
          !_teOtpDigitSix.text.isEmpty) {
        _isMobileNumberEnter = true;
      } else {
        _isMobileNumberEnter = false;
      }
      setState(() {});
    });
  }

  void _submit() {
    try {
      if (_isMobileNumberEnter) {
        showLoader();
        presenter.verifyOtp(_teOtpDigitOne.text +
            _teOtpDigitTwo.text +
            _teOtpDigitThree.text +
            _teOtpDigitFour.text +
            _teOtpDigitFive.text +
            _teOtpDigitSix.text);
      } else {
        showAlert("Please enter valid OTP!");
      }
    } catch (e) {
      showAlert("error occured OTP!");
    }
  }

  @override
  Widget build(BuildContext context) {
    var otpBox = new Row(
      children: <Widget>[
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitOne,
            focusNode: _focusNodeDigitOne,
            keyboardType: TextInputType.number,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitTwo,
            focusNode: _focusNodeDigitTwo,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitThree,
            focusNode: _focusNodeDigitThree,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitFour,
            focusNode: _focusNodeDigitFour,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitFive,
            focusNode: _focusNodeDigitFive,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitSix,
            focusNode: _focusNodeDigitSix,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );

    var form = new Column(
      children: <Widget>[
        new Container(
          alignment: FractionalOffset.center,
          margin: EdgeInsets.fromLTRB(40.0, 50.0, 40.0, 0.0),
          padding: EdgeInsets.all(20.0),
          decoration: new BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: new BorderRadius.all(
              const Radius.circular(6.0),
            ),
          ),
          child: new Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                new Text(
                  "Enter valid recieved OTP",
                ),
                new Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                  child: otpBox,
                ),
                new SizedBox(
                  width: 0.0,
                  height: 20.0,
                ),
                new Text(
                  otpWaitTimeLabel,
                ),
                new GestureDetector(
                  onTap: () {
                    _submit();
                  },
                  child: new Container(
                    margin: EdgeInsets.only(top: 20.0),
                    padding: EdgeInsets.all(15.0),
                    alignment: FractionalOffset.center,
                    decoration: new BoxDecoration(
                      color: new Color(0xFF2CB044),
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(6.0)),
                    ),
                    child: Text(
                      "Verify OTP",
                      style: new TextStyle(
                          color: const Color(0xFFFFFFFF),
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    var screenRoot = new Container(
      height: double.maxFinite,
      alignment: FractionalOffset.center,
      child: new SingleChildScrollView(
        child: new Center(
          child: form,
        ),
      ),
    );
    return new WillPopScope(
        onWillPop: () async {
          print("back");
          return true;
        },
        child: new Scaffold(
          backgroundColor: const Color(0xFF2B2B2B),
          appBar: null,
          key: _scaffoldKey,
          body: ProgressHUD(
            child: screenRoot,
            inAsyncCall: _isLoading,
            opacity: 0.0,
          ),
        ));
  }

  void changeFocusListener(
      TextEditingController teOtpDigitOne, FocusNode focusNodeDigitTwo) {
    teOtpDigitOne.addListener(() {
      if (teOtpDigitOne.text.length > 0 && focusNodeDigitTwo != null) {
        FocusScope.of(context).requestFocus(focusNodeDigitTwo);
      }
      setState(() {});
    });
  }

  @override
  void closeLoader() {
    setState(() => _isLoading = false);
  }

  @override
  void showAlert(String msg) {
    setState(() {
      //AppUtil().showAlert(msg);
      Alert(
        context: context,
        type: AlertType.error,
        title: "ALERT",
        desc: msg,
        buttons: [
          DialogButton(
            child: Text(
              "Done",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    });
  }

  @override
  void showLoader() {
    setState(() => _isLoading = true);
  }

  @override
  onError(String msg) {
    setState(() {
      debugPrint(msg);
      //AppUtil().showAlert(msg);
      Alert(
        context: context,
        type: AlertType.error,
        title: "ALERT",
        desc: "Check your OTP again",
        buttons: [
          DialogButton(
            child: Text(
              "Done",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage())),
            width: 120,
          )
        ],
      ).show();
    });
    closeLoader();
  }

  void startTimer() {
    var sub = new CountDown(new Duration(minutes: 5)).stream.listen(null);
    sub.onData((Duration d) {
      setState(() {
        int sec = d.inSeconds % 60;
        otpWaitTimeLabel = d.inMinutes.toString() + ":" + sec.toString();
      });
    });
  }

  @override
  verificationCodeSent(int forceResendingToken) {}

  @override
  void moveUserDashboardScreen(FirebaseUser currentUser) async {
    //phoneTabEnable();
    closeLoader();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('Loggedin', true);
    print('passed the login shared preferencess ${currentUser.uid}');
    bool girl = false, protector = false;

    /*(() async {
      var query =
          await Firestore.instance.collection("girl_user").getDocuments();
      var list = query.documents;
      print('the await sentence length came ${list.length}');
    })();*/

    Firestore.instance
        .collection('girl_user')
        .getDocuments()
        .then((QuerySnapshot qs_girl) {
      List<DocumentSnapshot> doc = qs_girl.documents;
      print('girl user length ${doc.length}');
      qs_girl.documents.forEach((DocumentSnapshot snap) {
        print("Current snp is ${snap.documentID}");
        print("current user id is ${currentUser.uid}");
        if (snap.documentID == currentUser.uid) {
          debugPrint("I am girl user");
          girl = true;
          //TODO add token in girl user collection
          final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
          _firebaseMessaging.getToken().then((token) {
            print(token);
            Firestore.instance
                .collection('girl_user')
                .document(currentUser.uid)
                .setData({'NotifyToken': token}, merge: true);
          });
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => girlHomeScreen(currentUser)));
        }
      });
    });
    Firestore.instance
        .collection('protector')
        .getDocuments()
        .then((QuerySnapshot qs_protector) {
      List<DocumentSnapshot> doc = qs_protector.documents;
      print('protector user length ${doc.length}');
      qs_protector.documents.forEach((DocumentSnapshot snap) {
        print("Current snp is ${snap.documentID}");
        print("current user id is ${currentUser.uid}");
        if (snap.documentID == currentUser.uid) {
          debugPrint("I am protector user");
          protector = true;
          //TODO add token in protector user collection
          final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
          _firebaseMessaging.getToken().then((token) {
            print(token);
            Firestore.instance
                .collection('protector')
                .document(currentUser.uid)
                .setData({'NotifyToken': token}, merge: true);
          });
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => protectorHomeScreen(currentUser)));
        }
      });
      if ((!girl) && (!protector)) {
        print('i got insidde regisering as a role');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => setUserRole(currentUser)));
      }
    });
  }

  @override
  onLoginUserVerified(FirebaseUser currentUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('Loggedin', true);

    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfilePage1(),),);
  }
}
