import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:onetap/personalChatroom.dart';
import 'package:shared_preferences/shared_preferences.dart';

//change app id in showupdate stream---------------------------
class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController fc = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  int myindex;
  bool tapped = false;
  String connwith = '...';
  bool feeddialog = false;
  String id = '';
  @override
  void initState() {
    super.initState();
    readmyid();
    // getmyindex();
  }

  invite() async {
    final ByteData bytes = await rootBundle.load('images/signup.png');

    await Share.file('Thank you so much. You are special for us.',
        'signup.png', bytes.buffer.asUint8List(), 'image/png',
        text:
            'Hey, Live chat with people around the world on onetap instant messenger. https://play.google.com/store/apps/details?id=com.getorionapp.onetap');
  }

  feeddialogbox() {
    var unit = MediaQuery.of(context).size.width / 100;
    return showDialog(
        context: context,
        builder: (c) {
          return Form(
            key: _formkey,
            child: AlertDialog(
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
                FlatButton(
                    onPressed: () {
                      if (_formkey.currentState.validate()) {
                        FirebaseFirestore.instance
                            .collection('feedback')
                            .doc(id)
                            .set({
                          'feedback': fc.text,
                          'time': DateFormat.yMEd()
                              .add_jms()
                              .format(DateTime.now()),
                        }).then((value) {
                          Fluttertoast.showToast(msg: 'Sent Successfully');
                          Navigator.pop(context);
                        });
                      }
                      //validation
                    },
                    child: Text('Submit')),
              ],
              title: Text(
                'Feedback',
              ),
              content: Container(
                height: unit * 40,
                child: TextFormField(
                  maxLines: null,
                  validator: (v) {
                    if (v.trim().isEmpty) {
                      return 'Please Write Something';
                    }
                  },
                  controller: fc,
                  decoration: InputDecoration(),
                  autofocus: true,
                ),
              ),
            ),
          );
        });
  }

  readmyid() async {
    SharedPreferences pr = await SharedPreferences.getInstance();
    setState(() {
      id = pr.getString('id');
    });
    print('my id ' + id);
    // getmyindex();
  }

  // getmyindex() {
  //   Future<DocumentSnapshot> ds =
  //       FirebaseFirestore.instance.collection('users').doc(id).get();

  //   ds.then((value) {
  //     setState(() {
  //       myindex = value.data()['index'];
  //     });
  //     print(myindex);
  //   });
  // }

  // bool bizer
  //
  // int liveusers = 0;
  handletap() {
    setState(() {
      tapped = true;
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'tp': false}).then((value) {
      // var un = '';
      var unit = MediaQuery.of(context).size.width / 100;
      Future<QuerySnapshot> qs = FirebaseFirestore.instance
          .collection('users')
          // .where('index', isNotEqualTo: myindex)
          .where('isonline', isEqualTo: true)

          // .limit(1)
          // .where('isonline', isEqualTo: true)
          .where('status', isEqualTo: true)
          .where('tp', isEqualTo: true)
          .orderBy('chattime', descending: false)
          .limit(1)
          .get();

      qs.then((value) {
        value.size == 1
            ? setState(() {
                connwith = value.docs[0]['username'];

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(value.docs[0]['username'])
                    .update({
                  'incomingRequest': true,
                  'connectedwith': id
                }).then((_) {
                  setState(() {
                    tapped = false;
                    connwith = '...';
                  });
                  //          Navigator.pushAndRemoveUntil(
                  // context,
                  // MaterialPageRoute(
                  //     builder: (BuildContext context) => ),
                  // (Route<dynamic> route) => false);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => PersonalChatroom(
                                myId: id,
                                peerId: value.docs[0]['username'],
                              )));
                });
                // FirebaseFirestore.instance
                //     .collection('users')
                //     .doc(value.docs[0]['username'])
                //     .update({
                //   'chattime': DateTime.now().millisecondsSinceEpoch
                // }).then((value) {
                //   print('updated chattime');
                // });
              })
            : showDialog(
                context: context,
                builder: (c) => AlertDialog(
                      actions: [
                        FlatButton(
                            onPressed: () {
                              setState(() {
                                tapped = false;
                              });
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(id)
                                  .update({'tp': true});
                              Navigator.pop(context);
                            },
                            child: Text('Okay'))
                      ],
                      content: Text(
                          'Users are busy. Wait for a few seconds and try again.',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: unit * 5)),
                    ));
        print(connwith);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var unit = MediaQuery.of(context).size.width / 100;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: unit * 20,
                  ),

                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('isonline', isEqualTo: true)
                          .where('status', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SpinKitWave(
                            color: Theme.of(context).primaryColor,
                          );
                        }
                        print(snapshot.data.docs.length);
                        return (snapshot.data.docs.length - 1 == 0)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.redAccent,
                                    radius: unit * 3,
                                  ),
                                  SizedBox(
                                    width: unit * 5,
                                  ),
                                  Text(
                                    'Busy',
                                    style: TextStyle(
                                        fontFamily: 'Blinkerextra',
                                        color: Colors.redAccent,
                                        fontSize: unit * 5),
                                  )
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.teal,
                                    radius: unit * 3,
                                  ),
                                  SizedBox(
                                    width: unit * 5,
                                  ),
                                  Text(
                                    'Available',
                                    style: TextStyle(
                                        fontFamily: 'Blinkerextra',
                                        color: Colors.teal,
                                        fontSize: unit * 5),
                                  )
                                ],
                              );
                      }),

                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('isonline', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SpinKitWave(
                              color: Theme.of(context).primaryColor);
                        }
                        //TODO-----------change users live 
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          margin: EdgeInsets.symmetric(horizontal: unit * 3),
                          child: Card(
                            elevation: 30,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(unit * 5),
                                    child: Text(
                                      'Users live : ' + 
                                          (snapshot.data.docs.length - 1)
                                              .toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                          fontSize: unit * 9,
                                          fontFamily: 'RussoOne'),
                                    )),

                                // (snapshot.data.docs.length - 1) == 0 ? Text('')   Text('BUSY', style: TextStyle(color: Colors.red,fontSize: unit*5,fontFamily: 'PressStart2P' ),),
                                Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(unit * 5),
                                    child: Text(
                                      (snapshot.data.docs.length - 1) == 0
                                          ? 'Come back later'
                                          : 'Go Live Go Global',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: unit * 8,
                                          fontFamily: 'Blinkerextra'),
                                    )),
                                Container(
                                  padding: EdgeInsets.all(unit * 5),
                                  child: Text(
                                    (snapshot.data.docs.length - 1) == 0
                                        ? 'who knows who you will meet next'
                                        : 'Live Chat with people from all over the world',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: unit * 5,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                  StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('assets')
                          .doc('peaktime')
                          .snapshots(),
                      builder: (c, s) {
                        if (!s.hasData) {
                          return Container();
                        }
                        return Text(
                          'Peak Timing - ' + s.data.data()['peaktime'],
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        );
                      }),

                  // Text('Peak Time is 8:00 P.M',
                  //     style: TextStyle(
                  //       color: Theme.of(context).primaryColor,
                  //       fontSize: unit * 4,
                  //     )),

                  // SizedBox(height: unit*80,),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('isonline', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SpinKitWave(
                              color: Theme.of(context).primaryColor);
                        }
                        return Padding(
                          padding: EdgeInsets.all(unit * 5.0),
                          child: InkWell(
                            splashColor: Theme.of(context).primaryColor,
                            onTap: (snapshot.data.docs.length - 1) == 0
                                ? null
                                : () async {
                                    if (await ConnectivityWrapper
                                        .instance.isConnected) {
                                      //code goes here
                                      handletap();
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
                                  },
                            borderRadius: BorderRadius.circular(30),
                            child: Card(
                              elevation: 20,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Container(
                                  // height: ,
                                  // margin: EdgeInsets.all(unit * 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color:
                                          (snapshot.data.docs.length - 1) == 0
                                              ? Colors.grey
                                              : Theme.of(context).primaryColor),
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(unit * 5),
                                  child: Text(
                                    'Tap to Chat',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: unit * 5),
                                  )),
                            ),
                          ),
                        );
                      }),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: unit * 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            invite();
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: unit * 8, vertical: unit * 3),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Theme.of(context).primaryColor),
                            child: Text(
                              'Invite Friends',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: unit*1,),
                        InkWell(
                          onTap: () {
                            feeddialogbox();
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: unit * 8, vertical: unit * 3),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Theme.of(context).primaryColor),
                            child: Text(
                              'Send Feedback',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              tapped
                  ? Center(
                      child: Card(
                        elevation: 30,
                        shadowColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          height: unit * 30,
                          width: unit * 70,
                          padding: EdgeInsets.all(unit * 5),
                          child: Column(
                            children: [
                              Text(
                                'Connected with $connwith',
                                style: TextStyle(
                                    fontSize: unit * 4,
                                    color: Theme.of(context).primaryColor),
                              ),
                              SizedBox(
                                height: unit * 3,
                              ),
                              SpinKitWave(
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ));
  }
}
