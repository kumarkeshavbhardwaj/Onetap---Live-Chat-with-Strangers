import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    var unit = MediaQuery.of(context).size.width/100;
    return Scaffold(

      body: SafeArea(

              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Text('helio', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: unit*10),))
                      // ,Text('Last Max Live : 56', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: unit*10),)

          ],
        ),
      )


      
    );
  }
}