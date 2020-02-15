import 'package:flutter/cupertino.dart';

class helpingGirlScreen extends StatefulWidget {
  String girlid;
  var girl_docsnap;
  helpingGirlScreen(this.girlid, this.girl_docsnap);

  @override
  _helpingGirlScreenState createState() =>
      _helpingGirlScreenState(girlid, girl_docsnap);
}

class _helpingGirlScreenState extends State<helpingGirlScreen> {
  _helpingGirlScreenState(girlid, girl_docsnap);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child:
          Text('hello this is live location page of the girl u want to help'),
    );
  }
}
