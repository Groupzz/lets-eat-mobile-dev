import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lets_eat/Accounts/AccountManagement.dart';
import 'package:lets_eat/Accounts/updateUser.dart';
import 'authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'UserYelpPreferences.dart';
import 'package:lets_eat/Group.dart';
import 'package:lets_eat/ViewGroup.dart';
import 'signUpPage.dart';

class Accounts extends StatefulWidget {
  Accounts({Key key, this.auth, this.userId, this.username, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;
  final String username;
  String friendsID;

  @override
  State<StatefulWidget> createState() => new _AccountsState();
}

class _AccountsState extends State<Accounts> {

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;
  DatabaseReference itemRef;
  FirebaseUser user;
  String uid;
  //String username;
//  Future<FirebaseUser> user = FirebaseAuth.instance.currentUser();
//  FirebaseUser c =

//  void getCurrentUserInfo() async{
//    user = await FirebaseAuth.instance.currentUser();
//    await Future.delayed(const Duration(milliseconds: 700), (){});
//    //user = await FirebaseAuth.instance.currentUser();//auth.currentUser();
//
//
//    print("UID = " + widget.userId);
//
//    Firestore.instance.collection('users').where(
//        'id', isEqualTo: uid // Get current user id
//    ).snapshots().listen(
//      // Update Friends collection that contains current user ID
//            (data) =>
//        username = data.documents[0]['username']);
//    await Future.delayed(const Duration(milliseconds: 700), (){});
//    print("username = " + username);
//  }

  String _email = "";
  String _username = "";
  String _resetPasswordEmail = "";
  String _userId;

  String _errorMessage;
  bool _isIos;
  bool _isLoading;

    bool _isEmailVerified = false;

    void _showVerifyEmailSentDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Verify your account"),
            content:
            new Text("Link to verify account has been sent to your email"),
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

    void _resentVerifyEmail() {
      widget.auth.sendEmailVerification();
      _showVerifyEmailSentDialog();
    }

    void _showVerifyEmailDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Verify your account"),
            content: new Text(
                "Please verify account in the link sent to email"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Resent link"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resentVerifyEmail();
                },
              ),
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

    void _checkEmailVerification() async {
      user = await FirebaseAuth.instance.currentUser();
      _isEmailVerified = await widget.auth.isEmailVerified();
      if (!_isEmailVerified) {
        _showVerifyEmailDialog();
      }
    }


    @override
    void initState() {
      //getCurrentUserInfo();
      super.initState();
      //print("usernameefw =" + widget.username);
      //getCurrentUserInfo();
      itemRef = _database.reference().child('users');
      _checkEmailVerification();
    }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }


    _signOut() async {
      try {
        await widget.auth.signOut();
        widget.onSignedOut();
      } catch (e) {
        print(e);
      }
    }

    _showAccountManagement() {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          children: <Widget>[
            new MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              onPressed: () {
                Route route = MaterialPageRoute(builder: (context) =>
                    AccountManagement(
                      userId: widget.userId,
                      username: widget.username,
                      auth: widget.auth,
                      onSignedOut: widget.onSignedOut,
                    ));
                Navigator.push(context, route);
              },
              minWidth: MediaQuery
                  .of(context)
                  .size
                  .width,
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              color: Colors.lightBlue,
              textColor: Colors.white,
              child: Text(
                "Account Management",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    _showChangePreferences() {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          children: <Widget>[
            new MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              onPressed: () {
                Route route = MaterialPageRoute(
                    builder: (context) => UserYelpPreferences());
                Navigator.push(context, route);
              },
              minWidth: MediaQuery
                  .of(context)
                  .size
                  .width,
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              color: Colors.blueAccent,
              textColor: Colors.white,
              child: Text(
                "Choose My Preferences",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    Future<List<Group>> getGroups() async {
      // Get friends list for current user
      //getCurrentUserInfo();
      List<Group> groups = [];

      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      String username = currentUser.displayName;

      await Future.delayed(const Duration(
          milliseconds: 700), () {}); // Wait for promise to return friendsID
      Firestore.instance.collection("groups").where(
          'Participants', arrayContains: username).snapshots().forEach((
          QuerySnapshot snapshot) {
        snapshot.documents.forEach((DocumentSnapshot snap) async {
          groups.add(Group.fromSnapshot(snap));
        });
      });
      await Future.delayed(const Duration(milliseconds: 700), () {});
      return groups;
    }

    Widget _showGroupsLabel() {
      return new Padding(
        padding: EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 0.0),
        child: Text("Active Groups:", style: new TextStyle(fontSize: 18.0)),
      );
    }

    Widget _showGroups() {
      // Display ListView of Friends
      //getCurrentUserInfo();
      return new Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 20.0),
          child: Center(
              child: FutureBuilder<List<Group>>(
                  future: getGroups(),
                  builder: (BuildContext c, AsyncSnapshot<List<Group>> data) {
                    if(data.data?.length == 0){
                      return Padding(padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "No Groups Found"));
                    }
                    if (data.hasData) {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                              itemCount: data.data.length,
                              itemBuilder: (c, index) {
                                return Center(
                                    child: Card(
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              //Padding(padding: const EdgeInsets.all(8.0)),
                                              ListTile(
                                                title: Text('${data.data[index]
                                                    .participants.toString()
                                                    .substring(1,
                                                    data.data[index]
                                                        .participants
                                                        .toString()
                                                        .length - 1)}'),
                                                onTap: () {
                                                  Route route = MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewGroupPage(
                                                              docId: data
                                                                  .data[index]
                                                                  .documentID));
                                                  Navigator.push(
                                                      context, route);
                                                },
                                              ),
                                            ])
                                    )
                                );
                              }
                          )
                      );
                    }
                    else if (data.hasError) {
                      print("error: " + data.error.toString());
                      return Padding(padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "You must be logged in to participate in Group Votes"));
                    }
//                  else {
//                    return Padding(padding: const EdgeInsets.all(8.0), child: Text("No Groups Found"));
//                  }

                    // By default, show a loading spinner
                    return CircularProgressIndicator();
                  }
              )
          )
      );
    }


    Widget _showButtonList() {
      return new Container(
        padding: EdgeInsets.all(26.0),
        child: new ListView(
          children: <Widget>[
            _showAccountManagement(),
            _showChangePreferences(),
            _showGroupsLabel(),
            SizedBox(
              height: 400.0,
              child: _showGroups(),
            )
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      //widget.onSignedOut();
      //getCurrentUserInfo();

      print("userid = " + widget.userId);
      String displayUName = widget?.username ?? "";
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('Hello, ' + widget.username??"user"),
//        title: new Text('Hello, '),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: _showButtonList(),
      );
    }
}