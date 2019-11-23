import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'Accounts/LoginSignUp.dart';
import 'Accounts/authentication.dart';
import 'Accounts/accounts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Friends.dart';
import 'Group.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class ViewGroupPage extends StatefulWidget {
  ViewGroupPage({this.docId});

  final String docId;
  @override
  _ViewGroupPageState createState() => _ViewGroupPageState();
}

class _ViewGroupPageState extends State<ViewGroupPage> {
  String groupDocID;
  final _formKey = new GlobalKey<FormState>();
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  List<String> users = [];
  final usernameController = TextEditingController();
  final prefController = TextEditingController();
  FirebaseUser user;
  QuerySnapshot userData;


  @override
  void initState() {
    super.initState();
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
    Firestore.instance.collection('groups').document(widget.docId).updateData({'Participants':FieldValue.arrayUnion([usernameController.text])});

    _showSuccess();
  }
  void _showSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("User added!"),
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

  void _displayAddPref() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('What Are You In The Mood For?'),
            content: TextField(
              controller: prefController,
              decoration: InputDecoration(hintText: "Enter a Food Preference"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('SUBMIT'),
                onPressed: () {
                  Firestore.instance.collection('groups').document(widget.docId).updateData({'Preferences':FieldValue.arrayUnion([prefController.text])});
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Your Preference has been added!"),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("Dismiss"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    }
                  );
                },
              )
            ],
          );
        });
  }

  Widget _showFriends() {  // Display ListView of Friends
    //getCurrentUserInfo();
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 135.0, 0.0, 200.0),
        child: Center(
            child: FutureBuilder<Group> (
                future: getFriends(),
                builder: (BuildContext c, AsyncSnapshot<Group> data) {
                  if(data.hasData) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: data.data.participants.length,
                            itemBuilder: (c, index) {
                              return Center(
                                  child: Card(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            //Padding(padding: const EdgeInsets.all(8.0)),
                                            ListTile(
                                              title: Text('${data.data.participants[index]}'),
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
    );
  }

  Widget _showPreferences() {  // Display ListView of Friends
    //getCurrentUserInfo();
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 135.0, 0.0, 200.0),
        child: Center(
            child: FutureBuilder<Group> (
                future: getFriends(),
                builder: (BuildContext c, AsyncSnapshot<Group> data) {
                  if(data.hasData) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: data.data.preferences.length,
                            itemBuilder: (c, index) {
                              return Center(
                                  child: Card(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            //Padding(padding: const EdgeInsets.all(8.0)),
                                            ListTile(
                                              title: Text('${data.data.preferences[index]}'),
                                            ),
                                          ])
                                  )
                              );
                            }
                        )
                    );
                  }
                  else if (data.hasError) {
                    return Padding(padding: const EdgeInsets.all(8.0), child: Text("No Preferences Found"));
                  }

                  // By default, show a loading spinner
                  return CircularProgressIndicator();
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


  Widget _showAddUsers(){
    _getCurrentUser();
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 50.0, 0.0),
      child: new TextFormField(
        controller: usernameController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Enter usernames to add to group',
            icon: new Icon(
              Icons.person,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
        onSaved: (value) => users.add(value),
      ),
    );
  }

  Widget _showAddUser(){
    return new Padding(
      padding: const EdgeInsets.fromLTRB(310.0, 10.0, 10.0, 0.0),
        child: SizedBox(
          width: 50,
          child: RaisedButton(
            onPressed: _updateData,
            child: Icon(Icons.person_add),
            color: Colors.grey[200],
          ),
        )
    );
  }


  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 70.0, 20.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Add Preference',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              _displayAddPref();
            },
          ),
        ));
  }

  Widget _showPrefsLabel() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(15.0, 120.0, 0.0, 0.0),
      child: Text("Preferences:", style: new TextStyle(fontSize: 18.0)),
    );
  }

  Widget _showStartButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(190.0, 70.0, 5.0, 0.0),
        child: SizedBox(
          height: 40.0,
          //width: 200,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            child: new Text('Find A Restaurant',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {

            },
          ),
        ));
  }

  Widget _showAddPreferencesButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Add a Preference',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              _displayAddPref();
            },
          ),
        ));
  }

  void removeGroup() async {
    await Firestore.instance.collection('groups').document(widget.docId).delete();
    Navigator.of(context).pop();
  }

  Widget _removeGroupButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(115.0, 540.0, 5.0, 0.0),
        child: SizedBox(
          height: 40.0,
          width: 200,
          child: new RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.red,
              child: new Text('Delete Group',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: () {
                removeGroup();
              }
          ),
        ));
  }


  @override
  Widget build(BuildContext context) {
    _getCurrentUser();
    // TODO: implement build
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("New Group Vote"),
        ),
        body: Stack(
          children: <Widget>[
            _showAddUsers(),
            _showPrimaryButton(),
            _showPrefsLabel(),
//            _showFriends(),
            _showStartButton(),
            _removeGroupButton(),
            _showAddUser(),
            _showPreferences(),
//            _showAddPreferencesButton(),
            //_showCircularProgress(),
          ],
        )
    );
  }
}