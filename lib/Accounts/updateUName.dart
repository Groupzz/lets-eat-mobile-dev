import 'dart:async' as prefix0;

import 'package:flutter/material.dart';
import 'authentication.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Friends.dart';

class UpdateUNamePage extends StatefulWidget {
  UpdateUNamePage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _UpdateUNamePageState();
}

class _UpdateUNamePageState extends State<UpdateUNamePage> {

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
            (data) => userData = data);
    //userDocID = data.documents[0].documentID);
    await Future.delayed(const Duration(milliseconds: 700), (){});
    userDocID = userData.documents[0].documentID;
  }

  void _checkUsername() async{
    var results = Firestore.instance.collection('users').where(
        'username', isEqualTo: controller.text // Get current user id
    );

    var querySnap = await results.getDocuments();
    var length = querySnap.documents.length;

    print("query returned " + length.toString() + "results");

    if(length == 0){
      _updateData();
    }
    else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Username already taken!"),
            //content: new Text("Link to verify account has been sent to your email"),
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

  void _updateData() async{
    print("user id = " + userDocID);
//    Firestore.instance.collection('users').where(
//        'username', isEqualTo: controller.text // Get current user id
//    ).snapshots().listen(
//      // Update Friends collection that contains current user ID
//            (data) => data.documents.length == 0 ?
//
//    );


    Firestore.instance.collection('users').document(userDocID).updateData({
      "username": controller.text.isEmpty? userData.documents[0]["username"] : controller.text,
    }
    );
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = controller.text.isEmpty? userData.documents[0]["username"] : controller.text;
    user.updateProfile(updateInfo);

    _showSuccess();
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Your Account Has Been Updated!"),
          //content: new Text("Link to verify account has been sent to your email"),
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

//  void changeUsername() async {
//    Firestore.instance.collection("users").document(userDocID)
//          .updateData({'username': controller.text,
//    "ignore": "test"});
//  }
//
//  void updateAndConfirm() async {
//    FirebaseUser user = await FirebaseAuth.instance.currentUser();
////    Firestore.instance.collection('users').document(userDocID).updateData(
////        {
////          "username": controller.text,
////        }
////    );
//    UserUpdateInfo updateInfo = UserUpdateInfo();
//    updateInfo.displayName = controller.text;
//    user.updateProfile(updateInfo);
//    changeUsername();
//
////    showDialog(
////      context: context,
////      builder: (BuildContext context) {
////        // return object of type Dialog
////        return AlertDialog(
////          title: new Text("Username changed!"),
////          content: new Text("${controller.text} has been added as a friend"),
////          actions: <Widget>[
////            new FlatButton(
////              child: new Text("Dismiss"),
////              onPressed: () {
////                Navigator.of(context).pop();
////              },
////            ),
////          ],
////        );
////      },
////    );
//    Navigator.of(context).pop();
//  }
//
//  void validateUsername() async{
//    Firestore.instance.collection('users').where('username', isEqualTo: controller.text).snapshots().listen(
//        (data) => data.documents.length > 0 ?
//        showDialog(
//          context: context,
//          builder: (BuildContext context) {
//            // return object of type Dialog
//            return AlertDialog(
//              title: new Text("User Not Found"),
//              content: new Text("We didn't find a user with that username.  Please make sure the username is correct"),
//              actions: <Widget>[
//                new FlatButton(
//                  child: new Text("Dismiss"),
//                  onPressed: () {
//                    //success = false;
//                    Navigator.of(context).pop();
//                  },
//                ),
//              ],
//            );
//          },
//        ) : updateAndConfirm()
//    );
//  }
//
//  void update() async  // Adds friend to friends db via username
//      {
//   // bool success = true;
////    final FirebaseUser user = await FirebaseAuth.instance.currentUser();//auth.currentUser();
////    uid = user.uid;
//    try {
//      // Check if provided username is in database
//      Firestore.instance.collection('users').where(
//          'username', isEqualTo: controller.text)
//          .snapshots().listen(
//
//              (data) => data.documents.length > 0
//          // If so, update user's friends array w/ new friend
//              ?
//              showDialog(
//                context: context,
//                builder: (BuildContext context) {
//                  // return object of type Dialog
//                  return AlertDialog(
//                    title: new Text("Username changed!"),
//                    content: new Text("Done"),
//                    actions: <Widget>[
//                      new FlatButton(
//                        child: new Text("Dismiss"),
//                        onPressed: () {
//                          //success = false;
//                          Navigator.of(context).pop();
//                        },
//                      ),
//                    ],
//                  );
//                },
//              )
//
//          // If not, show error message
//              :
//              updateAndConfirm()
//      );
//
////      Future<String> friendID = Firestore.instance.collection('friends').add({ // Add user to firestore w/ generated userID
////        "userID": uid,
////        "friends": [controller.text]
////      }).then((doc) {
////        print("Friend ID = " + doc.documentID);
////        return doc.documentID;
////      });
//
////        Firestore.instance.collection('users').where(
////          'id', isEqualTo: uid
////        ).snapshots().listen(
////            (data)=> Firestore.instance.collection("friends").document(data.documents[0]['friendsDocID']).updateData({'friends':FieldValue.arrayUnion([controller.text])})
////        );
//
////      Firestore.instance.collection('users').where(
//////          'username', isEqualTo: controller.text)
////          .snapshots().listen(
////
////              (data) => data.documents.length > 0
////                  ? Firestore.instance.collection('friends').add({ // Add user to firestore w/ generated userID
////                "userID": uid,
////                "friends": [controller.text]
////              })
////                  : showDialog(
////                    context: context,
////                    builder: (BuildContext context) {
////                      // return object of type Dialog
////                      return AlertDialog(
////                        title: new Text("User Not Found"),
////                        content: new Text("We didn't find a user with that username.  Please make sure the username is correct"),
////                        actions: <Widget>[
////                          new FlatButton(
////                            child: new Text("Dismiss"),
////                            onPressed: () {
////                              success = false;
////                              Navigator.of(context).pop();
////                            },
////                          ),
////                        ],
////                      );
////                    },
////                  )
////      );
//      //_showFriends();
//    }
//    catch(e)
//    {
////      showDialog(
////        context: context,
////        builder: (BuildContext context) {
////          // return object of type Dialog
////          return AlertDialog(
////            title: new Text("Verify your account"),
////            content: new Text("Link to verify account has been sent to your email"),
////            actions: <Widget>[
////              new FlatButton(
////                child: new Text("Dismiss"),
////                onPressed: () {
////                  Navigator.of(context).pop();
////                },
////              ),
////            ],
////          );
////        },
////      );
////      print("Not found");
//    }
//  }

  Widget _showUserName(){
    _getCurrentUser();
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: controller,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Username',
            //prefixText: userData.documents[0]["username"],
            icon: new Icon(
              Icons.perm_identity,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Uame can\'t be empty' : null,
        onSaved: (value) => username = value.trim(),
      ),
    );
  }



  Widget _showPrimaryButton() {
    //getCurrentUserInfo();
    return new Padding(
      padding: EdgeInsets.fromLTRB(275.0, 70.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        width: 100.0,
        child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Update',
                style: new TextStyle(fontSize: 16.0, color: Colors.white)),
            onPressed: _checkUsername
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Update Username'),
        ),
        body: Stack(
          children: <Widget>[
            _showUserName(),
            _showPrimaryButton(),
          ],
        ));
  }

}