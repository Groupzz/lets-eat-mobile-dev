import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'Accounts/LoginSignUp.dart';
import 'Accounts/authentication.dart';
import 'Accounts/accounts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'Friends.dart';
import 'Group.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class CreateGroupPage extends StatefulWidget {
  CreateGroupPage({this.docId});

  final String docId;
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  String groupDocID;
  final _formKey = new GlobalKey<FormState>();
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  //String _password;
  String _userId = "";
  List<String> users = [];
  final usernameController = TextEditingController();
  final locationController = TextEditingController();
  FirebaseUser user;
  QuerySnapshot userData;
  var location = new Location();


  @override
  void initState() {
    super.initState();
//    widget.auth.getCurrentUser().then((user) {
//      setState(() {
//        if (user != null) {
//          _userId = user?.uid;
//        }
//        authStatus =
//        user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
//      });
//    });
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

  Widget _showFriends() {  // Display ListView of Friends
    //getCurrentUserInfo();
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 200.0, 0.0, 70.0),
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

  Future<Group> getFriends() async{  // Get friends list for current user
    //getCurrentUserInfo();

//    print("FID = " + fid);
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
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
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

  Widget _showAddLocation(){
    _getCurrentUser();
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        controller: locationController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Current Location',
            icon: new Icon(
              Icons.location_on,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
        onSaved: (value) => users.add(value),
      ),
    );
  }

  Widget _showLocButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20.0, 150.0, 20.0, 0.0),
        child: SizedBox(
          height: 35.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Update Location',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: (){
              if(locationController.text.isNotEmpty) {
                Firestore.instance.collection('groups')
                    .document(widget.docId)
                    .updateData(
                    {
                      'location': locationController.text
                    }

                );
              }

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // return object of type Dialog
                  return AlertDialog(
                    title: new Text("Group Location Has Been Updated!"),
                    content: new Text("This location will be used to find the group's restaurant"),
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
            },
          ),
        ));
  }


  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20.0, 63.0, 20.0, 0.0),
        child: SizedBox(
          height: 35.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Add To Group',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _updateData,
          ),
        ));
  }

  void removeGroup() async {
    await Firestore.instance.collection('groups').document(widget.docId).delete();
    Navigator.of(context).pop();
  }

  Widget _removeUserButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(80.0, 540.0, 5.0, 0.0),
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
//    return new MaterialButton(
//      shape:
//      RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
//      onPressed: () {
//        Firestore.instance.document(widget.docId).delete();
//      },
//      minWidth: MediaQuery.of(context).size.width,
//      padding: EdgeInsets.fromLTRB(20.0, 300.0, 20.0, 0.0),
//      color: Colors.red,
//      textColor: Colors.white,
//      child: Text(
//        "Delete My Account",
//        textAlign: TextAlign.center,
//      ),
//    );
//  }

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
            _showAddLocation(),
            _showLocButton(),
            _showFriends(),
            _removeUserButton()
            //_showCircularProgress(),
          ],
        )
    );
  }
}