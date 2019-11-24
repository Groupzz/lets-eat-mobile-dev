import 'dart:async' as prefix0;

import 'package:flutter/material.dart';
import 'Accounts/authentication.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Friends.dart';

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
  String uid;
  String friendsID;
  String fDocID;
  final controller = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState(){
    _errorMessage = "";
    _isLoading = false;
    getCurrentUserInfo();  // store info for current user
    super.initState();
  }

  Future<void> addAndConfirmFriend(QuerySnapshot data) async {
    Firestore.instance.collection("friends").document(data.documents[0]['friendsDocID'])
        .updateData({'friends':FieldValue.arrayUnion([controller.text])});

    Firestore.instance.collection("users").where(
      'username', isEqualTo: controller.text).snapshots().listen(
        (data) => fDocID = data.documents[0]['friendsDocID']
    );

    await Future.delayed(const Duration(milliseconds: 700), (){});
    print("fDocID = " + fDocID);
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    String username = currentUser.displayName;
    print("username = " + username);
    Firestore.instance.collection("friends").document(fDocID).updateData(
      {'friends':FieldValue.arrayUnion([username])}
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Friend Added!"),
          content: new Text("${controller.text} has been added as a friend"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                controller.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addFriend() async  // Adds friend to friends db via username
  {
    bool success = true;
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();//auth.currentUser();
    uid = user.uid;
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
                      (data)=>
                          addAndConfirmFriend(data)
//                          Firestore.instance.collection("friends").document(data.documents[0]['friendsDocID'])
//                          .updateData({'friends':FieldValue.arrayUnion([controller.text])})
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

  void getCurrentUserInfo() async{
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();//auth.currentUser();
    uid = user.uid;
    print("UID = " + uid);

    Firestore.instance.collection('users').where(
        'id', isEqualTo: uid // Get current user id
    ).snapshots().listen(
        // Update Friends collection that contains current user ID
            (data) =>
            friendsID = data.documents[0]['friendsDocID']);
    //print("Friends ID = " + friendsID);
  }

  Widget _addFriendField()  // Display input field to add friend
  {
   // getCurrentUserInfo();
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        controller: controller,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Enter Friend\'s username',
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

  Future<Friends> getFriends() async{  // Get friends list for current user
    getCurrentUserInfo();

//    print("FID = " + fid);
    await Future.delayed(const Duration(milliseconds: 700), (){});  // Wait for promise to return friendsID
    return Firestore.instance.collection("friends").document(friendsID).get() // Get friends document for current user
        .then((snapshot) {
      try {
        return Friends.fromSnapshot(snapshot);
      } catch (e) {
        print("ERROR::: " + e);
        return null;
      }
    });


  }

  Widget _showPrimaryButton() {
    //getCurrentUserInfo();
    return new Padding(
        padding: EdgeInsets.fromLTRB(270.0, 70.0, 10.0, 0.0),
        child: SizedBox(
          height: 40.0,
          width: 150,
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

  Widget _showFriendsLabel(){
    return new Padding(
      padding: EdgeInsets.fromLTRB(15.0, 115.0, 0.0, 0.0),
      child: Text("Friends:", style: new TextStyle(fontSize: 18.0)),
    );
  }

  Widget _showFriends() {  // Display ListView of Friends
    //getCurrentUserInfo();
    return new Padding(
      padding: EdgeInsets.fromLTRB(10.0, 135.0, 0.0, 0.0),
      child: Center(
        child: FutureBuilder<Friends> (
          future: getFriends(),
          builder: (BuildContext c, AsyncSnapshot<Friends> data) {
            if(data.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: data.data.friends.length,
                  itemBuilder: (c, index) {
                    return Center(
                      child: Card(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            //Padding(padding: const EdgeInsets.all(8.0)),
                            ListTile(
                              title: Text('${data.data.friends[index]}'),
                            ),
                        ])
                      )
                    );
                }
                )
              );
            }
            else if (data.hasError) {
              return Padding(padding: const EdgeInsets.all(8.0), child: Text("No Friends Found"));
            }

            // By default, show a loading spinner
            return CircularProgressIndicator();
        }
        )
      )

//      child: SizedBox(
//        height: 100.0,
//        child: StreamBuilder<Friends>(
//          stream: getFriends(),
//          builder: (BuildContext c, AsyncSnapshot<Friends> data) {
//            if(data?.data == null) return Text("No Friends Found");
//            print("DATA =" + data.toString());
//            Friends friend = data.data;
//
//            return Text("Friends:\n\n${friend.friends}");
//          },
//        )
//      ),
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
            _showFriendsLabel(),
            _showFriends(),
            _addFriendField(),
            _showPrimaryButton(),
//            StreamBuilder<Friends>(
//              stream: getFriends(),
//              builder: (BuildContext c, AsyncSnapshot<Friends> data) {
//                if(data?.data == null) return Text("No Friends Found");
//                print("DATA =" + data.toString());
//                Friends friend = data.data;
//
//                return Text("${friend.friends}");
//              },
//            )
          ],
        ));
  }

}