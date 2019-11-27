import 'dart:async' as prefix0;

import 'package:flutter/material.dart';
import 'authentication.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Friends.dart';

class PasswordResetPage extends StatefulWidget {
  PasswordResetPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {

  bool _isIos;
  bool _isLoading;
  String _errorMessage;
  String _friendUName;
  String uid;
  String userDocID;
  String username;
  final controller = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;
  QuerySnapshot userData;
  String currentUName;

  @override
  void initState(){
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _getCurrentUser() async {
    user = await FirebaseAuth.instance.currentUser();
    uid = user.uid;
    Firestore.instance.collection('users').where(
        'id', isEqualTo: uid // Get current user id
    ).snapshots().listen(
      // Update Friends collection that contains current user ID
            (data) {
          userData = data;
          userDocID = data.documents[0].documentID;
        });
    //userDocID = data.documents[0].documentID);
    await Future.delayed(const Duration(milliseconds: 700), (){});
    //userDocID = userData.documents[0].documentID;
  }

  _showSentResetPasswordEmailContainer() {
    return Column(
      children: <Widget>[
        new Container(
          child: new TextFormField(
            controller: controller,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Enter Email",
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
            ),
          ),
        ),
        new MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          onPressed: () {
            _checkEmail();
          },
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          color: Colors.blueAccent,
          textColor: Colors.white,
          child: Text(
            "Send Password Reset Mail",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _checkEmail() async{
    var results;
    if(controller.text.isEmpty){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Email Can't Be Empty!"),
            //content: new Text("Link to verify account has been sent to your email"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Dismiss"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    else{
      results = Firestore.instance.collection('users').where(
          'email', isEqualTo: controller.text); // Get current user id


      if(results == null){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Please Check Your Email"),
              content: new Text("If the email you entered is registered, a link to reset your password was sent"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Dismiss"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      else {
        var querySnap = await results.getDocuments();
        var length = querySnap.documents.length;

        print("query returned " + length.toString() + "results");

        if (length > 0) {
          widget.auth.sendPasswordResetMail(controller.text);
          await Future.delayed(const Duration(milliseconds: 700), () {});
          _showSuccess();
        }
        else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("Please Check Your Email"),
                content: new Text("If the email you entered is registered, a link to reset your password was sent"),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Dismiss"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
  }
  }


  void _showSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Please Check Your Email"),
          content: new Text("If the email you entered is registered, a link to reset your password was sent"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showEmail(){
    _getCurrentUser();
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: controller,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Enter Your Email',
            //prefixText: userData.documents[0]["username"],
            icon: new Icon(
              Icons.email,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => username = value.trim(),
      ),
    );
  }



  Widget _showPrimaryButton() {
    //getCurrentUserInfo();
    return new Padding(
      padding: EdgeInsets.fromLTRB(10.0, 70.0, 10.0, 0.0),
      child: SizedBox(
        height: 40.0,
        //width: 100.0,
        child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Reset My Password',
                style: new TextStyle(fontSize: 16.0, color: Colors.white)),
            onPressed: _checkEmail
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Reset Your Password'),
        ),
        body: Stack(
          children: <Widget>[
            _showEmail(),
            _showPrimaryButton(),
          ],
        ));
  }

}