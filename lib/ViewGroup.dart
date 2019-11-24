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
  String result;

  var location = new Location();
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};
  final _random = new Random();

  List<dynamic> preferences;

  bool done = false;
  bool viewPref = true;
  bool viewFind = true;

  Widget _buildResultButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 400.0, 0.0, 20.0),
        child: Center(
          child: done
              ? RaisedButton(
            color: Colors.green,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            child: Text('View Restaurant'),
            onPressed: () {
              loadRestaurant();
            },
          )
              : SizedBox(),
        ),
      );
  }

  void loadRestaurant() async {
    var resultDoc = Firestore.instance.collection('groups').document(widget.docId);
    resultDoc.get().then((resultDoc) {
      result = resultDoc['Result'];
    });
    await Future.delayed(const Duration(milliseconds: 700), (){});
    print("Restaurant ID result = " + result);

    String siteAddress = "https://api.yelp.com/v3/businesses/" + result; //-118.112858";

    //webAddress = "https://api.yelp.com/v3/businesses/search?latitude=33.783022&longitude=-118.112858";

    http.Response response;
    Map<String, dynamic> map;
    response =
    await http.get(siteAddress, headers: AUTH_HEADER).catchError((resp) {});

    //Map<String, dynamic> map;
    // Error handling
    //    response == null
    //    ? response = await http.get(webAddress, headers: AUTH_HEADER).catchError((resp) {})
    //    : map = json.decode(response.body);
    if (response == null || response.statusCode < CODE_OK ||
        response.statusCode >= CODE_REDIRECTION) {
      return Future.error(response.body);
    }

    //    Map<String, dynamic> map = json.decode(response.body);
    map = json.decode(response.body);
    var r = json.decode(response.body);
    print("r == " +  r.toString());
    Route route = MaterialPageRoute(builder: (context) => GroupRestaurantPage(result: r,));
    Navigator.push(context, route);
//    Iterable jsonList = map["businesses"];
//    List<Restaurants> businesses = jsonList.map((model) =>
//        Restaurants.fromJson(model)).toList();
//    print(jsonList.toString());
  }



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
                  Navigator.of(context).pop();
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
            child: StreamBuilder(
                stream: Firestore.instance.collection('groups').document(widget.docId).snapshots(),
                builder: (context, data) {
                  if(data.hasData) {
                    var doc = data.data;
                    List<dynamic> prefs = doc['Preferences'];
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
//                            itemCount: data.data.preferences.length,
                              itemCount: prefs.length,
                            itemBuilder: (c, index) {
                              return Center(
                                  child: Card(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            //Padding(padding: const EdgeInsets.all(8.0)),
                                            ListTile(
                                              title: Text('${prefs[index]}'),
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
          child: viewPref ?
            new RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.blue,
              child: new Text('Add Preference',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: () {
                _displayAddPref();
              },
            )
              :
              SizedBox()
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
          width: 175,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            child: new Text('Find A Restaurant',
                style: new TextStyle(fontSize: 15.0, color: Colors.white)),
            onPressed: () {
              setState(() {
                generateQuery();
                //done = true;
                viewPref = false;
              });
            },
          ),
        ));
  }

  void generateQuery() async{
    var gDoc = Firestore.instance.collection('groups').document(widget.docId);
    gDoc.get().then((gDoc) {
      preferences = gDoc['Preferences'];
    });
    await Future.delayed(const Duration(milliseconds: 700), (){});
    String query = preferences.toString().substring(1, preferences.toString().length - 1);
    print("Preferences = " + query);
    findRandomRestaurant(query).then((resultID) {
      Firestore.instance.collection('groups').document(widget.docId).updateData({'Result': resultID});
      print("resultID = " + resultID);
      //done = true;
    }).then((resultID) {
      setState(() {
        done = true;
      });
    });
   /// await Future.delayed(const Duration(seconds: 2), (){});
//    setState(() {
//      done = true;
//    });
  }

  Widget _showAddPreferencesButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: viewPref ?

            new RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.blue,
              child: new Text('Add a Preference',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: () {
                _displayAddPref();
              },
            )
          :
            SizedBox()
        ));
  }

  void removeGroup() async {
    Navigator.of(context).pop();
    await Firestore.instance.collection('groups').document(widget.docId).delete();

  }

  Widget _removeGroupButton() {
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


  Future<String> findRandomRestaurant(String query) async {
    String webAddress;
    var latitude;
    var longitude;
    var currentLocation = await location.getLocation();
    latitude = currentLocation.latitude;
    longitude = currentLocation.longitude;

    webAddress = "https://api.yelp.com/v3/businesses/search?term=" + query + "&limit=50"; //-118.112858";
    if(!webAddress.contains("location")){
      webAddress += "&latitude=" + latitude.toString() + "&longitude=" + longitude.toString();
    }

    //webAddress = "https://api.yelp.com/v3/businesses/search?latitude=33.783022&longitude=-118.112858";
    print("latitude = " + latitude.toString() + "; longitude = " +
        longitude.toString());
    http.Response response;
    Map<String, dynamic> map;
    response =
    await http.get(webAddress, headers: AUTH_HEADER).catchError((resp) {});

    //Map<String, dynamic> map;
    // Error handling
    //    response == null
    //    ? response = await http.get(webAddress, headers: AUTH_HEADER).catchError((resp) {})
    //    : map = json.decode(response.body);
    if (response == null || response.statusCode < CODE_OK ||
        response.statusCode >= CODE_REDIRECTION) {
      return Future.error(response.body);
    }

    //    Map<String, dynamic> map = json.decode(response.body);
    map = json.decode(response.body);
    Iterable jsonList = map["businesses"];
    List<Restaurants> businesses = jsonList.map((model) =>
        Restaurants.fromJson(model)).toList();
    print(jsonList.toString());
    for (Restaurants restaurant in businesses) {
      print("Restaurant: " + restaurant.name);
    }
    //print("Businesses: " + businesses.toString());

    // Pick random restaurant from results
    int min = 0;
    int max = businesses.length;
    int i = min + _random.nextInt(max - min);
    return businesses[i].id;

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
            _buildResultButton(),
//            _showAddPreferencesButton(),
            //_showCircularProgress(),
          ],
        )
    );
  }
}