import 'package:flutter/material.dart';
import 'authentication.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsPage extends StatefulWidget {
  FriendsPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {

  bool _isIos;
  bool _isLoading;
  String _errorMessage;
  String _friendUName;
  final controller = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void addFriend() async
  {
    bool success = true;
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();//auth.currentUser();
    final uid = user.uid;
    try {
      // Check if provided username is in database
      Firestore.instance.collection('users').where(
          'username', isEqualTo: controller.text)
          .snapshots().listen(

              (data) => data.documents.length > 0
              // If so, update user's friends array w/ new friend
              ? Firestore.instance.collection('users').where(
                  'id', isEqualTo: uid // Get current user id
              ).snapshots().listen(
                // Update Friends collection that contains current user ID
                      (data)=> Firestore.instance.collection("friends").document(data.documents[0]['friendsDocID']).updateData({'friends':FieldValue.arrayUnion([controller.text])})
              )
              // If not, show error message
              : showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("User Not Found"),
                content: new Text("We didn't find a user with that username.  Please make sure the username is correct"),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Dismiss"),
                    onPressed: () {
                      success = false;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          )
      );
//      Future<String> friendID = Firestore.instance.collection('friends').add({ // Add user to firestore w/ generated userID
//        "userID": uid,
//        "friends": [controller.text]
//      }).then((doc) {
//        print("Friend ID = " + doc.documentID);
//        return doc.documentID;
//      });

//        Firestore.instance.collection('users').where(
//          'id', isEqualTo: uid
//        ).snapshots().listen(
//            (data)=> Firestore.instance.collection("friends").document(data.documents[0]['friendsDocID']).updateData({'friends':FieldValue.arrayUnion([controller.text])})
//        );

//      Firestore.instance.collection('users').where(
////          'username', isEqualTo: controller.text)
//          .snapshots().listen(
//
//              (data) => data.documents.length > 0
//                  ? Firestore.instance.collection('friends').add({ // Add user to firestore w/ generated userID
//                "userID": uid,
//                "friends": [controller.text]
//              })
//                  : showDialog(
//                    context: context,
//                    builder: (BuildContext context) {
//                      // return object of type Dialog
//                      return AlertDialog(
//                        title: new Text("User Not Found"),
//                        content: new Text("We didn't find a user with that username.  Please make sure the username is correct"),
//                        actions: <Widget>[
//                          new FlatButton(
//                            child: new Text("Dismiss"),
//                            onPressed: () {
//                              success = false;
//                              Navigator.of(context).pop();
//                            },
//                          ),
//                        ],
//                      );
//                    },
//                  )
//      );
    }
    catch(e)
    {
//      showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          // return object of type Dialog
//          return AlertDialog(
//            title: new Text("Verify your account"),
//            content: new Text("Link to verify account has been sent to your email"),
//            actions: <Widget>[
//              new FlatButton(
//                child: new Text("Dismiss"),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                },
//              ),
//            ],
//          );
//        },
//      );
//      print("Not found");
    }
  }

  Widget _addFriendField()
  {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        controller: controller,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Enter Username of the Friend You Want To Add',
            icon: new Icon(
              Icons.person_add,
              color: Colors.grey,
            )
        ),
        validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
        onSaved: (value) => _friendUName = value.trim(),
      ),
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(300.0, 70.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Add Friend',
                style: new TextStyle(fontSize: 16.0, color: Colors.white)),
              onPressed: addFriend
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Friends'),
        ),
        body: Stack(
          children: <Widget>[
            _addFriendField(),
            _showPrimaryButton(),
          ],
        ));
  }

}