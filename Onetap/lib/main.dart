import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:onetap/homepage.dart';
import 'package:onetap/usernamepage.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
runApp(MaterialApp(debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'JosefinSans',
      primaryColor: Color.fromRGBO(0, 188, 212, 1),
      accentColor: Color.fromRGBO(77, 208, 225, 1),
    ),
    title: 'Onetap',
    home: SplashScreen(),
  ));
  });

  

  
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String id = '';
  @override
  void initState() {
    checkinternetstatus();
    // checkifloggedin();
    super.initState();
  }

  checkinternetstatus() async {
    if (await ConnectivityWrapper.instance.isConnected) {
      // quitandfindother();
      checkifloggedin();
    } else {
      print('no internet');
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'No Internet',
                style: TextStyle(
                    // fontFamily: 'Righteous',
                    ),
              ),
              content: Text(
                'Connect to Internet. If you are connected to internet, then restart the app :)',
                style: TextStyle(
                    // fontFamily: 'Righteous',
                    ),
              ),
            );
          });
    }
  }

  updateonlinestatus() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'isonline': true, 'status' : true, 'incomingRequest' : false, 'tp': true, 'quit' : false, 'connectedwith' : '...'}).then((value) {
                 Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => HomePage(
                            id,
                          )),
                  (Route<dynamic> route) => false);
      
      
    });
  }

  checkifloggedin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id');
    });
    // var id =

    if (id != null) {
      updateonlinestatus();
      // Navigator.push(context, MaterialPageRoute(builder: (c)=> HomePage(id)));

    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => UsernamePage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var unit = MediaQuery.of(context).size.width / 100;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Colors.white,
      backgroundColor: Color.fromRGBO(0, 188, 212, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Container(
          //     alignment: Alignment.center,
          //     child: Text(
          //       'onetap',
          //       style: TextStyle(
          //           fontFamily: 'Blinkerextra',
          //           color: Colors.white,
          //           fontSize: unit * 15,
          //           fontWeight: FontWeight.w900),
          //     )),
          // SizedBox(
          //   height: unit * 4,
          // ),

          // Container(
          //     alignment: Alignment.center,
          //     child: Text(
          //       'Chat live on onetap instant messenger',
          //       style: TextStyle(
          //           fontFamily: 'Blinkerthin',
          //           color: Colors.white,
          //           fontSize: unit * 5,
          //           fontWeight: FontWeight.bold),
          //     )),
              SpinKitWave(
            color: Colors.white,size: unit*20,
          ),
        ],
      ),
    );
  }
}
