

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:onetap/FirstScreen.dart';
import 'package:onetap/SettingsScreen.dart';
import 'package:onetap/personalChatroom.dart';
import 'package:store_redirect/store_redirect.dart';



class HomePage extends StatefulWidget {
  final String id;
  HomePage(this.id);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    updatedailycounts();
    updateonline();
    // updateonlinestatus();
  }

  updatedailycounts() {
    print(DateFormat.yMMMMd('en_US').add_jm().format(DateTime.now()));
    FirebaseFirestore.instance.collection('users').doc(widget.id).update({
      'dailycounts': FieldValue.arrayUnion(
          [DateFormat.yMMMMd('en_US').add_jm().format(DateTime.now())])
    });
  }

  // int index = 0;

  int selectedindex = 0;

  void handler(int index) {
    setState(() {
      selectedindex = index;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        updateoffline();
        // updategone();
        // updateengagement();

        print('app is paused');
        break;

      case AppLifecycleState.inactive:
        updateoffline();
        // updategone();
        // updateengagement();
        print('app is inactive');

        break;

      case AppLifecycleState.resumed:
        updateonline();
        // updategone();
        // updateengagement();
        print('app is resumed');

        break;

      case AppLifecycleState.detached:
        updateoffline();
        // updategone();
        print('app is detached');

        break;
    }
  }

  updateoffline() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .update({'isonline': false});



    print('called offline');
  }

  updateonline() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .update({'isonline': true});
          

    print('called online');
  }

  static List<Widget> _widgetOptions = <Widget>[
    FirstScreen(),
    SettingsScreen(),
  ];

  Future<bool> onBackPress() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .update({'isonline': false});
    print('cleared');
    SystemNavigator.pop();

    return Future.value(false);
  }

  reader(peerid) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => PersonalChatroom(
                  myId: widget.id,
                  peerId: peerid,
                )));
  }

  @override
  Widget build(BuildContext context) {
    print(widget.id);
    var unit = MediaQuery.of(context).size.width / 100;
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        //invite your friends on instant messenger
        body: Stack(
          children: [
            FirstScreen(),
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else if (snapshot.data.data()['incomingRequest'] == true) {
                    Timer(Duration(seconds: 3), () {
                      reader(snapshot.data.data()['connectedwith']);
                    });
                    return Center(
                      child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 30,
                          shadowColor: Theme.of(context).primaryColor,
                          child: Container(
                            alignment: Alignment.center,
                            height: unit * 50,
                            width: unit * 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'connected with ${snapshot.data.data()['connectedwith']}',
                                  style: TextStyle(
                                      fontSize: unit * 5,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor),
                                ),
                                SizedBox(
                                  height: unit * 5,
                                ),
                                SpinKitWave(
                                  color: Theme.of(context).primaryColor,
                                )
                              ],
                            ),
                          )),
                    );
                  } else if (snapshot.data.data()['showupdate'] == true) {
                    return AlertDialog(
                      actions: [
                        FlatButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.id)
                                  .update({'showupdate': false});
                              //TODO1------------0000-0-0-0-0-0-0-0-0-0-0-0-0-00-0-0-0000-----;;;;
                              //Must Modify befor release-------------------------
                              StoreRedirect.redirect(
                                  androidAppId: 'com.getorionapp.onetap');
                            },
                            child: Text('Okay'))
                      ],
                      title: Text('New Update Available'),
                      content: Text(
                          'Update your app now or app might become unusable. If done already, ignore this message.'),
                    );
                  } else {
                    return Container();
                  }
                }),
          ],
        ),
      ),
    );
  }
}
