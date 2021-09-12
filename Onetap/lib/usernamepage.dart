import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:onetap/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsernamePage extends StatefulWidget {
  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final TextEditingController uc = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool loader = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //backend
  //

  updateindex(String userid) async {
    print('init index');
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) {
      int length = value.size - 1;
      var docref = FirebaseFirestore.instance.collection('users').doc(userid);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(docref, {'index': length});
      });
      print('index will be $length');
    });
  }

  usercreation() async {
        var unit = MediaQuery.of(context).size.width / 100;

    SharedPreferences preferences = await SharedPreferences.getInstance();

    _auth.signInAnonymously().then((result) {
      setState(() {
        final User user = result.user;
      });
      print('uid is' + result.user.uid);

      //check if the user exists with same username

      Future<DocumentSnapshot> checker =
          FirebaseFirestore.instance.collection('users').doc(uc.text.trim()).get();

      checker.then((value) {
        setState(() {
          loader = false;
        });
        if (value.exists) {
          // yes exists
          return showDialog(
              context: context,
              builder: (c) => AlertDialog(
                    title: Text('Username already taken', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
                    content: Container(

                      height: unit*30,
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Pick a different funny username', style: TextStyle(color: Theme.of(context).primaryColor),),
                          SizedBox(height: unit*10,),
                          Text('xD' ,style: TextStyle(fontFamily: 'PressStart2P', fontSize: unit*10, color: Theme.of(context).primaryColor)),
                        ],
                      ),
                    ),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              uc.text = '';
                            });
                          },
                          child: Text('Okay'))
                    ],
                  ));
        } else {
          //new and valid username
          FirebaseFirestore.instance.collection('users').doc(uc.text.trim()).set({
            'username': uc.text,
            'createdat': DateFormat.yMEd().add_jms().format(DateTime.now()),
            'devtoken': null,
            'quit' : false,

            'incomingRequest': false,
            'tp': true,
            'connectedwith': 'onetap user',
            'chattime': DateTime.now().millisecondsSinceEpoch,
            'index': null,
            'uid': result.user.uid,
            'isonline': false,
            'chatting' : false,
            'status': true,
            'dailycounts': [],
            'chattedwith': 0,
            'islive': false,
            'showupdate': false,
          }).then((value) async {
            _firebaseMessaging.getToken().then((val) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(uc.text.trim())
                  .update({
                'devtoken': val,
              });
              preferences.setString('FCMtoken', val);
              print('Token for this user: ' + val);

              updateindex(uc.text.trim());
            });

            setState(() {
              loader = false;
            });

            await preferences.setString('id', uc.text.trim());
 Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage(
                    uc.text.trim(),
                  )),
          (Route<dynamic> route) => false);
            // Navigator.push(
            //     context, MaterialPageRoute(builder: (c) => HomePage(uc.text.trim())));


          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var unit = MediaQuery.of(context).size.width / 100;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if(await ConnectivityWrapper.instance.isConnected) {
if (_formkey.currentState.validate()) {
            setState(() {
              loader = true;
            });
            usercreation();
          }
          } else {
            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'No Internet',
                                    style: TextStyle(
                                      fontFamily: 'PressStart2P',
                                    ),
                                  ),
                                  content: Text(
                                    'Check your Internet Connection',
                                    style: TextStyle(
                                      fontFamily: 'PressStart2P',
                                    ),
                                  ),
                                );
                              });
          }
          //http status==200 ?

          
        },
        child: Icon(Icons.arrow_forward_ios, color: Colors.white),
      ),
      body: Form(
        key: _formkey,
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(unit * 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: unit * 5,
                    ),
                    Text(
                      'Pick a funny username',
                      style: TextStyle(
                          fontFamily: 'JosefinSans',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: unit * 5),
                    ),
                    SizedBox(
                      height: unit * 5,
                    ),
                    Container(
                      child: TextFormField(
                        autovalidate: false,
                        keyboardType: TextInputType.visiblePassword,
                        controller: uc,
                        validator: (v) {
                          if (v.trim().isEmpty || v == '') {
                            return 'Cannot be empty';
                          }
                        },
                        cursorColor: Theme.of(context).accentColor,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontFamily: 'JosefinSans',
                            // fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: unit * 8),
                        autofocus: true,
                        autocorrect: false,
                        decoration: InputDecoration(
                            hintStyle: TextStyle(
                              fontFamily: 'JosefinSans',
                              fontSize: unit * 4,
                            ),
                            hintText: 'ex : Katappa, kala bakra'),
                      ),
                    ),
                  ],
                ),
              ),
              loader
                  ? Center(
                      child: Card(
                        elevation: 50,
                        child: Container(
                          width: unit*70,
                          height: unit * 50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(unit * 2.0),
                                child: Text(
                                  'Hang on...',
                                  style: TextStyle(
                                      fontSize: unit * 5,
                                      fontFamily: 'Blinkerextra',
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                              SpinKitWave(
                                color: Theme.of(context).primaryColor
                              ),
                              
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
