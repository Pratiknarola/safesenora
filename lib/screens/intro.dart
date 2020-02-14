import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:prototype/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  SharedPreferences prefs;
  IntroScreen(this.prefs);

  @override
  _IntroScreenState createState() => _IntroScreenState(prefs);
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();
  SharedPreferences prefs;
  _IntroScreenState(this.prefs);

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "Level 1",
        styleTitle: TextStyle(
          color: Color(0xff4DC133),
          fontSize: 30.0,
          fontWeight: FontWeight.bold, /*fontFamily: 'RobotoMono'*/
        ),
        description:
            "Allow miles wound place the leave had. To sitting subject no improve studied limited",
        styleDescription: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontStyle: FontStyle.italic, /*fontFamily: 'Raleway'*/
        ),
        backgroundColor: Color(0xFFFFDEAD),
      ),
    );
    slides.add(
      new Slide(
        title: "Level 2",
        styleTitle: TextStyle(
          color: Color(0xffFA9020),
          fontSize: 30.0,
          fontWeight: FontWeight.bold, /*fontFamily: 'RobotoMono'*/
        ),
        description:
            "Allow miles wound place the leave had. To sitting subject no improve studied limited",
        styleDescription: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontStyle: FontStyle.italic, /*fontFamily: 'Raleway'*/
        ),
        backgroundColor: Color(0xFFFFDEAD),
      ),
    );
    slides.add(
      new Slide(
        title: "Level 3",
        styleTitle: TextStyle(
          color: Colors.red,
          fontSize: 30.0,
          fontWeight: FontWeight.bold, /*fontFamily: 'RobotoMono'*/
        ),
        description:
            "Allow miles wound place the leave had. To sitting subject no improve studied limited",
        styleDescription: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontStyle: FontStyle.italic, /*fontFamily: 'Raleway'*/
        ),
        backgroundColor: Color(0xFFFFDEAD),
      ),
    );
  }

  void onDonePress() async {
    await prefs.setBool('seen', true);
    Route route = MaterialPageRoute(builder: (context) => LoginPage());
    Navigator.pushReplacement(context, route);
  }

  void onSkipPress() async {
    await prefs.setBool('seen', true);
    Route route = MaterialPageRoute(builder: (context) => LoginPage());
    Navigator.pushReplacement(context, route);
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Colors.lightBlue,
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Color(0xffD02090),
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Color(0xffD02090),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IntroSlider(
        slides: this.slides,
        renderSkipBtn: this.renderSkipBtn(),
        onSkipPress: this.onSkipPress,
        colorSkipBtn: Color(0x33000000),
        highlightColorSkipBtn: Color(0xff000000),

        // Next, Done button
        onDonePress: this.onDonePress,
        renderNextBtn: this.renderNextBtn(),
        renderDoneBtn: this.renderDoneBtn(),
        colorDoneBtn: Color(0x33000000),
        highlightColorDoneBtn: Color(0xff000000),

        // Dot indicator
        colorDot: Color(0x33D02090),
        colorActiveDot: Color(0xffD02090),
        sizeDot: 13.0,
      ),
    );
  }
}
