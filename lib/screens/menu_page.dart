import 'package:flutter/material.dart';
import 'package:prototype/screens/ProfilePage1.dart';
import 'package:provider/provider.dart';

import './zoom_scaffold.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        //on swiping left
        if (details.delta.dx < -6) {
          Provider.of<MenuController>(context, listen: true).toggle();
        }
      },
      child: Container(
        padding: EdgeInsets.only(
            top: 62,
            left: 32,
            bottom: 8,
            right: MediaQuery.of(context).size.width / 2.9),
        color: Color(0xff454dff),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Tatiana',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                )
              ],
            ),
            Spacer(),
            Column(
              children: <Widget>[
                ListTile(
                    leading: Icon(
                      Icons.perm_identity,
                      color: Colors.white,
                      size: 20,
                    ),
                    title: Text(
                      'Profile',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
                ListTile(
                    onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (ctx) => ProfilePage1())),
                    leading: Icon(
                      Icons.shopping_basket,
                      color: Colors.white,
                      size: 20,
                    ),
                    title: Text(
                      'Basket',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
                ListTile(
                    leading: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 20,
                    ),
                    title: Text(
                      'Family Members',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
                ListTile(
                    leading: Icon(
                      Icons.people_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    title: Text(
                      'Trusted People',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
                Spacer(),
                ListTile(
                  onTap: () {},
                  leading: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                  title: Text('Settings',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(
                    Icons.headset_mic,
                    color: Colors.white,
                    size: 20,
                  ),
                  title: Text('Support',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*class MenuItem {
  String title;
  IconData icon;

  MenuItem(this.icon, this.title);
}
*/