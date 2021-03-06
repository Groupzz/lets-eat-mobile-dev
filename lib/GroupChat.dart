import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lets_eat/GroupRestaurant.dart';
import 'Accounts/LoginSignUp.dart';
import 'Accounts/authentication.dart';
import 'Accounts/accounts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Friends.dart';
import 'Group.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lets_eat/About.dart';
import 'package:location/location.dart';
import 'maps.dart';
import 'dart:math';
import 'Restaurants.dart';
import 'YelpRepository.dart';



class GroupChatPage extends StatefulWidget {
  GroupChatPage({this.docId});

  final String docId;
  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> with SingleTickerProviderStateMixin {
  String groupDocID;
  final _formKey = new GlobalKey<FormState>();
  String _userId = "";
  List<String> users = [];
  final messageController = TextEditingController();
  final prefController = TextEditingController();
  FirebaseUser user;
  QuerySnapshot userData;
  String result;

  bool isLoading;
  bool isShowSticker;

  List<String> choices = <String>[
    "Reset Group Vote",
    "Delete Group",
  ];

  var location = new Location();
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};
  final _random = new Random();

  List<dynamic> preferences;

  bool done = false;
  bool viewStart = true;
  bool viewPref = true;
  bool viewFind = true;

  final FocusNode _focusNode = new FocusNode();

  AnimationController _controller;
  Animation _animation;


//  @override
////  void initState() {
////    super.initState();
////    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
////    _animation = Tween(begin: 300.0, end: 50.0).animate(_controller)
////      ..addListener(() {
////        setState(() {});
////      });
////
////    isLoading = false;
////    isShowSticker = false;
////
////    void onFocusChange() {
////      if (_focusNode.hasFocus) {
////        // Hide sticker when keyboard appear
////        setState(() {
////          isShowSticker = false;
////        });
////      }
////    }
////
////
////    _focusNode.addListener(onFocusChange);
////  }


  void initState() {
    super.initState();
    _focusNode.addListener(onFocusChange);

    isLoading = false;
    isShowSticker = false;
  }

  void onFocusChange() {
    if (_focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      //Firestore.instance.collection('users').document(id).updateData({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

//  Widget buildInput() {
//    return new Padding(
//        padding: EdgeInsets.fromLTRB(10.0, 415.0, 0.0, 20.0),
//      child: Container(
//        child: Row(
//          children: <Widget>[
//            // Button send image
//            // Edit text
//            Flexible(
//              child: Container(
//                child: TextField(
//                  style: TextStyle(fontSize: 15.0),
//                  controller: messageController,
//                  decoration: InputDecoration.collapsed(
//                    hintText: 'Type your message...',
//                    hintStyle: TextStyle(color: Colors.grey),
//                  ),
//                  focusNode: _focusNode,
//                ),
//              ),
//            ),
//
//
//
//            // Button send message
//            Material(
//              child: new Container(
//                margin: new EdgeInsets.symmetric(horizontal: 8.0),
//                child: new IconButton(
//                  icon: new Icon(Icons.send),
//                  onPressed: _updateData,
//                ),
//              ),
//              color: Colors.white,
//            ),
//          ],
//        ),
//        width: double.infinity,
//        height: 50.0,
//        decoration: new BoxDecoration(
//            border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
//      ));
//  }

  Widget buildInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 20.0),
      child: Container(
          child: Row(
            children: <Widget>[

              // Button send image
              // Edit text
              Flexible(
                child: Container(
                  child: TextField(
                    style: TextStyle(fontSize: 15.0),
                    controller: messageController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: _focusNode,
                  ),
                ),
              ),



              // Button send message
              Material(
                child: new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 8.0),
                  child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: () {
                      if(messageController.text.isNotEmpty){
                        _updateData();
                      }
                    }
                  ),
                ),
                color: Colors.white,
              ),
            ],
          ),
          width: double.infinity,
          height: 50.0,
          decoration: new BoxDecoration(
              border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
      ));
  }

  void _getCurrentUser() async {
    user = await FirebaseAuth.instance.currentUser();
    _userId = user.uid;
    Firestore.instance.collection('users').where(
        'id', isEqualTo: _userId // Get current user id
    ).snapshots().listen(
      // Update Friends collection that contains current user ID
            (data) => userData = data);
    //userDocID = data.documents[0].documentID);
    await Future.delayed(const Duration(milliseconds: 700), (){});
    groupDocID = userData.documents[0].documentID;

  }

  void _updateData() async{
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    await Future.delayed(const Duration(milliseconds: 700), (){});
    String username = currentUser.displayName;
    String amPM = "AM";
    int hour = DateTime.now().hour;
    int minute = DateTime.now().minute;
    String strMin = minute.toString();
    if(minute < 10){
      strMin = "0"+minute.toString();
    }
    if(hour >= 13){
      hour -= 12;
      amPM = "PM";
    }
    if(hour == 12){
      amPM = 'PM';
    }
    if(hour == 0){
      hour = 12;
    }
    Firestore.instance.collection('groups').document(widget.docId).updateData(
        {'Messages':FieldValue.arrayUnion([username + ":  " + messageController.text]),
        'Timestamps': FieldValue.arrayUnion([DateTime.now().month.toString() + "/" + DateTime.now().day.toString() + 
        "/" + DateTime.now().year.toString() + "    " +  hour.toString() + ":" + strMin + " " + amPM + " " + DateTime.now().millisecondsSinceEpoch.toString()])}
    );
    messageController.clear();
  }

  Widget _showMessages() {  // Display ListView of messages
    //getCurrentUserInfo();
    String timestamp;
    String sender;
    String message;
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 30.0, 0.0, 60.0),
        child: Center(
            child: StreamBuilder(
                stream: Firestore.instance.collection('groups').document(widget.docId).snapshots(),
                builder: (context, data) {
                  try {
                    if (data.hasData) {
                      var doc = data.data;
                      List<dynamic> prefs = doc['Messages'];
                      List<dynamic> timestamps = doc['Timestamps'];
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            //                            itemCount: data.data.preferences.length,
                              itemCount: prefs.length,
                              itemBuilder: (c, index) {
                                timestamp = timestamps[index].toString().substring(0, timestamps[index].toString().indexOf('M')+1);
                                sender = prefs[index].toString().substring(0, prefs[index].toString().indexOf(':'));
                                message = prefs[index].toString().substring(prefs[index].toString().indexOf(':') + 1, prefs[index].toString().length);
                                return Center(
                                    child: Card(
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              //Padding(padding: const EdgeInsets.all(8.0)),
                                              ListTile(
                                                //leading: Text('${sender}', style: TextStyle(color: Colors.grey),),
                                                title: Text('${message}'),
                                                subtitle: Text('${sender}             ${timestamp}', textAlign: TextAlign.left,),
                                              ),
                                            ])
                                    )
                                );
                              }
                          )
                      );
                    }
                    else if (data.hasError) {
                      return Padding(padding: const EdgeInsets.all(8.0),
                          child: Text("No Messages Found"));
                    }

                    // By default, show a loading spinner
                    return CircularProgressIndicator();
                  }
                  catch(e){
                    return Padding(padding: const EdgeInsets.all(8.0),
                        child: Text("No Chat Found"));
                  }
                }
            )
        )
    );
  }


  Future<Group> getFriends() async{  // Get friends list for current user
    await Future.delayed(const Duration(milliseconds: 700), (){});  // Wait for promise to return friendsID
    return Firestore.instance.collection("groups").document(widget.docId).get() // Get friends document for current user
        .then((snapshot) {
      try {
        return Group.fromSnapshot(snapshot);
      } catch (e) {
        print("ERROR::: " + e);
        return null;
      }
    });
  }


  Widget _showSendMessage(){
    _getCurrentUser();
    final FocusNode _sendFocus = FocusNode();
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 415.0, 0.0, 20.0),
      child: TextFormField(
      controller: messageController,
      maxLines: 1,
      keyboardType: TextInputType.text,
      autofocus: false,
      focusNode: _focusNode,
      //focusNode: _sendFocus,
      decoration: new InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Enter Message",
        border:
        OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
      ),
      validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
      onSaved: (value) => users.add(value),
    ));


//    return InkWell( // to dismiss the keyboard when the user tabs out of the TextField
//      splashColor: Colors.transparent,
//      onTap: () {
//        FocusScope.of(context).requestFocus(FocusNode());
//      },
//      child: Padding(
//        padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, MediaQuery.of(context).viewInsets.bottom),
//
////
////        padding: EdgeInsets.only(
////            bottom: MediaQuery.of(context).viewInsets.bottom),
//          child: new TextFormField(
//          controller: messageController,
//          maxLines: 1,
//          keyboardType: TextInputType.text,
//          autofocus: false,
//          focusNode: _focusNode,
//          //focusNode: _sendFocus,
//          decoration: new InputDecoration(
//          //contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//          hintText: "Enter Message",
//          border:
//          OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
//          ),
//          validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
//          onSaved: (value) => users.add(value),
//          ),
//          )
//          );
  }

  Widget _showSend(){
    return new Padding(
        padding: const EdgeInsets.fromLTRB(310.0, 10.0, 10.0, 0.0),
        child: SizedBox(
            width: 50,
            child: RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.blue,
              child: Icon(Icons.send, color: Colors.white,),
              onPressed: () {
                if(messageController.text.length == 0) {
                  _updateData();
                }
              },
            )
        )
    );
  }

  Widget _showButtonList() {
    return new Container(
      padding: EdgeInsets.all(26.0),
      child: new ListView(
        shrinkWrap: true,
        children: <Widget>[
          new SizedBox(
            height: 300.0,
            child: _showMessages()
          ),
          buildInput(),
        ],
      ),
    );
  }


//
  @override
  Widget build(BuildContext context) {
//    _getCurrentUser();
//
//
//    return new Scaffold(
//        resizeToAvoidBottomPadding: false,
//        appBar: AppBar(
//            title: Text("Group Chat"),
//
//        ),
//        body: WillPopScope(
//          child: Stack(
//            children: <Widget>[
//                  _showPrefsLabel(),
//                  _showMessages(),
////                  _showSendMessage(),
//              Container(
//                alignment: Alignment.bottomCenter,
//                width: MediaQuery.of(context).size.width,
//                child: Container(
//                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
//                  color: Colors.grey[700],
//                  child: Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: TextField(
//                          controller: messageController,
//                          style: TextStyle(
//                              color: Colors.white
//                          ),
//                          decoration: InputDecoration(
//                              hintText: "Send a message ...",
//                              hintStyle: TextStyle(
//                                color: Colors.white38,
//                                fontSize: 16,
//                              ),
//                              border: InputBorder.none
//                          ),
//                        ),
//                      ),
//
//                      SizedBox(width: 12.0),
//
//                      GestureDetector(
//                        onTap: () {
//                          if(messageController.text.isNotEmpty){
//                            _updateData();
//                          };
//                        },
//                        child: Container(
//                          height: 50.0,
//                          width: 50.0,
//                          decoration: BoxDecoration(
//                              color: Colors.blueAccent,
//                              borderRadius: BorderRadius.circular(50)
//                          ),
//                          child: Center(child: Icon(Icons.send, color: Colors.white)),
//                        ),
//                      )
//                    ],
//                  ),
//                ),
//              )
//                //  _showSend(),
//                ],
//              ),
//
//          onWillPop: onBackPress,
//        )
//    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Chat", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        //backgroundColor: Colors.black87,
        backgroundColor: Colors.blue,
        elevation: 0.0,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            _showMessages(),
            // Container(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                color: Colors.grey[400],
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: TextStyle(
                            color: Colors.white
                        ),
                        decoration: InputDecoration(
                            hintText: "Send a message ...",
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            border: InputBorder.none
                        ),
                      ),
                    ),

                    SizedBox(width: 12.0),

                    GestureDetector(
                      onTap: () {
                        _updateData();
                      },
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: Center(child: Icon(Icons.send, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


//  @override
//  Widget build(BuildContext context) {
//    return WillPopScope(
//      child: Stack(
//        children: <Widget>[
//          Column(
//            children: <Widget>[
//              // List of messages
//              _showSend(),
//              _showSendMessage(),
//              _showPreferences(),
//              _showPrefsLabel(),
//            ],
//          ),
//        ],
//      ),
//      onWillPop: onBackPress,
//    );
//  }
}

