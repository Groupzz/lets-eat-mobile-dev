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
import 'GroupChat.dart';


/**
 * Displays the selected group.
 * Users can add preferences, view the group chat, and generate a restaurant from this page
 */
class ViewGroupPage extends StatefulWidget {
  ViewGroupPage({this.docId});

  final String docId;  // Document ID for Group data
  @override
  _ViewGroupPageState createState() => _ViewGroupPageState();
}

class _ViewGroupPageState extends State<ViewGroupPage> {
  String groupDocID;
  final _formKey = new GlobalKey<FormState>();
  String _userId = "";
  List<String> users = [];
  final usernameController = TextEditingController();
  final prefController = TextEditingController();
  FirebaseUser user;
  QuerySnapshot userData;
  String result;

  // Drop down menu options
  List<String> choices = <String>[
    "Reset Group Vote",
    "Delete Group",
  ];

  // Get device's current location
  var location = new Location();
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};
  final _random = new Random();

  List<dynamic> preferences;

  bool done = false;
  bool viewStart = true;
  bool viewPref = true;
  bool viewFind = true;

  void loadRestaurant() async {
    // Load group document and get the stored result id if it exists
    var resultDoc = Firestore.instance.collection('groups').document(widget.docId);
    resultDoc.get().then((resultDoc) {
      result = resultDoc['Result']??"";  // If a result has not been generated, store an empty string
    });
    await Future.delayed(const Duration(milliseconds: 700), (){});
    print("Restaurant ID result = " + result);

    String siteAddress = "https://api.yelp.com/v3/businesses/" + result; // Load restaurant's yelp site

    //webAddress = "https://api.yelp.com/v3/businesses/search?latitude=33.783022&longitude=-118.112858";

    http.Response response;
    Map<String, dynamic> map;
    response =
    await http.get(siteAddress, headers: AUTH_HEADER).catchError((resp) {});  // Call Yelp API

    //Map<String, dynamic> map;
    // Error handling
    //    response == null
    //    ? response = await http.get(webAddress, headers: AUTH_HEADER).catchError((resp) {})
    //    : map = json.decode(response.body);
    if (response == null || response.statusCode < CODE_OK ||  // Error check
        response.statusCode >= CODE_REDIRECTION) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Unable to find a restaurant.  Please modify your preferences"),
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
      //return Future.error(response.body);
    }

    //    Map<String, dynamic> map = json.decode(response.body);
    map = json.decode(response.body);
    var r = json.decode(response.body); // Decode API response
    print("r == " +  r.toString());
    Route route = MaterialPageRoute(builder: (context) => GroupRestaurantPage(result: r,));  // Load page displaying result of group vote
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

  // Get currently signed in user
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

  // Add specified username to group
  void _updateData() async{

    Firestore.instance.collection('groups').document(widget.docId).updateData({'Participants':FieldValue.arrayUnion([usernameController.text])});
    usernameController.clear();

    _showSuccess();
  }

  // Display success message for adding user
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

  // Show dialog box to add a preference
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
                  // Send new preference to group vote document
                  Firestore.instance.collection('groups').document(widget.docId).updateData({'Preferences':FieldValue.arrayUnion([prefController.text])});
                  prefController.clear();
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

  // Open stream to group document to check if a result has been saved
  Widget _buildResultButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 420.0),
      child: Center(
          child: StreamBuilder(
              stream: Firestore.instance.collection('groups').document(widget.docId).snapshots(),
              builder: (context, data) {
                try {
                  if (data.hasData) {
                    var doc = data.data ?? "";
                    String res = doc['Result'] ?? "";
                    try {
                      // If result has been saved for the group, display the View Restaurant button
                      if (res.length > 0) {
                        return new RaisedButton(
                          color: Colors.green,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          child: new Text('View Restaurant',
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          onPressed: () {
                            loadRestaurant();
                          },
                        );
                      }

                      else {
                        return Center();
                      }
                    }
                    catch (e) {
                      return Center();
                    }
                  }
                  else if (data.hasError) {
                    return Padding(padding: const EdgeInsets.all(8.0),
                        child: Text("Unable to load restaurant"));
                  }

                  // By default, show a loading spinner
                  return Center();
                }
                catch(e) {
                  return Padding(padding: const EdgeInsets.all(8.0),
                      child: Text("Unable to load restaurant"));
                }
              }
          )
      ),
    );
  }

  Widget _showPreferences() {  // Display ListView of Preferences
    //getCurrentUserInfo();
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 135.0, 0.0, 200.0),
        child: Center(
            child: StreamBuilder(
              // Open stream to group document
                stream: Firestore.instance.collection('groups').document(widget.docId).snapshots(),
                builder: (context, data) {
                  try {
                    if (data.hasData) {
                      var doc = data.data;
                      // Load saved preferences
                      List<dynamic> prefs = doc['Preferences'] ?? [];
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            //                            itemCount: data.data.preferences.length,
                              itemCount: prefs.length ?? 0,
                              itemBuilder: (c, index) {
                                return Center(
                                    child: Card(
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              //Padding(padding: const EdgeInsets.all(8.0)),
                                              ListTile(
                                                  title: Text(
                                                      '${prefs[index]}'),
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (
                                                          BuildContext context) {
                                                        // return object of type Dialog
                                                        return AlertDialog(
                                                          title: new Text(
                                                              "Delete this preference?"),
                                                          //content: new Text("Link to verify account has been sent to your email"),
                                                          actions: <Widget>[
                                                            new FlatButton(
                                                              child: new Text(
                                                                  "No"),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            new FlatButton(
                                                              child: new Text(
                                                                  "Yes",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red)),
                                                              onPressed: () {
                                                                Firestore
                                                                    .instance
                                                                    .collection(
                                                                    'groups')
                                                                    .document(
                                                                    widget
                                                                        .docId)
                                                                    .updateData(
                                                                    {
                                                                      'Preferences': FieldValue
                                                                          .arrayRemove(
                                                                          [
                                                                            prefs[index]
                                                                          ])
                                                                    });
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
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
                          child: Text("No Preferences Found"));
                    }

                    // By default, show a loading spinner
                    return CircularProgressIndicator();
                  }
                  catch(e) {
                    return Padding(padding: const EdgeInsets.all(8.0),
                        child: Text("No Preferences Found"));
                  }
                }
            )
        )
    );
  }

  Future<Group> getFriends() async{  // Get Group document
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

  // Show add username text box
  Widget buildInput() {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 20.0),
        child: Container(
          child: Row(
            children: <Widget>[

              // Button send image
              // Edit text
              Flexible(
                child: Container(
                  child: TextField(
                    style: TextStyle(fontSize: 15.0),
                    controller: usernameController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Enter username to add to group',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    //focusNode: _focusNode,
                  ),
                ),
              ),



              // Button send message
              Material(
                child: new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 8.0),
                  child: new IconButton(
                      icon: new Icon(Icons.person_add),
                      onPressed: () {
                        if(usernameController.text.isNotEmpty){
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



  Widget _showAddUsers(){
    _getCurrentUser();
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 0.0, 50.0, 0.0),
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
      padding: const EdgeInsets.fromLTRB(310.0, 0.0, 10.0, 0.0),
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

  Widget _showChat(){
    return new Padding(
        padding: const EdgeInsets.fromLTRB(60.0, 400.0, 10.0, 0.0),
        child: SizedBox(
          width: 250,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Group Chat',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (context) => GroupChatPage(docId: widget.docId,));
              Navigator.push(context, route);
            },
          )
        )
    );
  }


//  Widget _showPrimaryButton() {
//    return new Padding(
//        padding: EdgeInsets.fromLTRB(10.0, 70.0, 20.0, 0.0),
//        child: SizedBox(
//          height: 40.0,
//          child: viewPref ?
//            new RaisedButton(
//              elevation: 5.0,
//              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
//              color: Colors.blue,
//              child: new Text('Add Preference',
//                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
//              onPressed: () {
//                _displayAddPref();
//              },
//            )
//              :
//              SizedBox()
//        ));
//  }


  // Show button to add a preference if a restaurant has not already been found
  Widget _showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 200.0, 420.0),
      child: Center(
          child: StreamBuilder(
            // Open stream to group document
              stream: Firestore.instance.collection('groups').document(widget.docId).snapshots(),
              builder: (context, data) {
                try {
                  if (data.hasData) {
                    var doc = data.data ?? "";
                    String res = doc['Result'].toString();
                    // Check if a result has been saved
                    try {
                      // If not, allow preference to be added
                      if (res.length == 0 || doc['Result'] == null) {
                        return new RaisedButton(
                          elevation: 5.0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: Colors.blue,
                          child: new Text('Add Preference',
                              style: new TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                          onPressed: () {
                            _displayAddPref();
                          },
                        );
                      }

                      else {
                        return Center();
                      }
                    }
                    catch (e) {
                      return Center();
                    }
                  }
                  else if (data.hasError) {
                    return Padding(padding: const EdgeInsets.all(8.0),
                        child: Text("No Preferences Found"));
                  }

                  // By default, show a loading spinner
                  return Center();
                }
                catch(e) {
                  return Padding(padding: const EdgeInsets.all(8.0),
                      child: Text(""));
                }
              }
          )
      ),
    );
  }

  // Show preferences label
  Widget _showPrefsLabel() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(15.0, 120.0, 0.0, 0.0),
      child: Text("Preferences:", style: new TextStyle(fontSize: 18.0)),
    );
  }

//  Widget _showStartButton() {
//    return new Padding(
//        padding: EdgeInsets.fromLTRB(190.0, 70.0, 5.0, 0.0),
//        child: SizedBox(
//          height: 40.0,
//          width: 175,
//          child: viewStart? new RaisedButton(
//            elevation: 5.0,
//            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
//            color: Colors.green,
//            child: new Text('Find A Restaurant',
//                style: new TextStyle(fontSize: 15.0, color: Colors.white)),
//            onPressed: () {
//              setState(() {
//                generateQuery();
//                //done = true;
//                viewPref = false;
//                viewStart = false;
//              });
//            },
//          )
//          : Center(),
//        ));
//  }

  // Show button to start vote (find a restaurant for the group), if one hasn't already been done
  Widget _showStartButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(190.0, 0.0, 5.0, 420.0),
      child: Center(
          child: StreamBuilder(
              stream: Firestore.instance.collection('groups').document(widget.docId).snapshots(),
              builder: (context, data) {
                try {
                  if (data.hasData) {
                    var doc = data.data;
                    String res = doc['Result'].toString();
                    try {
                      // If length of result is positive, don't show the button
                      if (res.length == 0 || doc['Result'] == null) {
                        return new RaisedButton(
                          elevation: 5.0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: Colors.green,
                          child: new Text('Find A Restaurant',
                              style: new TextStyle(
                                  fontSize: 15.0, color: Colors.white)),
                          onPressed: () {
                            setState(() {
                              generateQuery();
                              //done = true;
                              viewPref = false;
                              viewStart = false;
                            });
                          },
                        );
                      }

                      else {
                        return Center();
                      }
                    }
                    catch (e) {
                      return Center();
                    }
                  }
                  else if (data.hasError) {
                    return Padding(padding: const EdgeInsets.all(8.0),
                        child: Text("No Preferences Found"));
                  }

                  // By default, show a loading spinner
                  return Center();
                }
                catch(e){
                    return Padding(padding: const EdgeInsets.all(8.0),
                        child: Text(
                            ""));
                }
              }
          )
      ),
    );
  }

  // Prepare & execute Yelp API call
  void generateQuery() async{
    // Get group document
    var gDoc = Firestore.instance.collection('groups').document(widget.docId);
    String location;
    var lat;
    var long;
    // Get data from the group document
    gDoc.get().then((gDoc) {
      preferences = gDoc['Preferences']??"";
      location = gDoc['location']??"";
      lat = gDoc['lat'];
      long = gDoc['long'];
    });
    await Future.delayed(const Duration(milliseconds: 700), (){});
    // Parse the preferences and add to the  query string
    String query = preferences.toString().substring(1, preferences.toString().length - 1);
    print("Preferences = " + query + "\nlocation = " + location);
    // Add location to the query
    if(location.length == 0){
      // Use current location if no location specified
      query += "&latitude=" + lat.toString() + "&longitude=" + long.toString();
    }
    else{
      // Use specified location
      query += "&location=" + location;
    }
    print("query = " + query);
    // Call yelp API and store result
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

  // Delete the group
  void removeGroup() async {
    Navigator.of(context).pop();
    await Firestore.instance.collection('groups').document(widget.docId).delete();

  }

  // Call Yelp API to get random restaurant for group
  Future<String> findRandomRestaurant(String query) async {
    String webAddress;
    var latitude;
    var longitude;
    var currentLocation = await location.getLocation();
    latitude = currentLocation.latitude;
    longitude = currentLocation.longitude;

    webAddress = "https://api.yelp.com/v3/businesses/search?term=" + query;// + "&limit=50"; //-118.112858";

    //webAddress = "https://api.yelp.com/v3/businesses/search?latitude=33.783022&longitude=-118.112858";
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Unable to find a restaurant.  Please modify your preferences"),
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
    if(max == 0){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Unable to find a restaurant.  Please modify your preferences"),
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
    else {
      int i = min + _random.nextInt(max - min);
      return businesses[i].id;
    }

  }


//  Widget _threeItemPopup() => PopupMenuButton(
//    itemBuilder: (context) {
//      var list = List<PopupMenuEntry<Object>>();
//      list.add(
//        PopupMenuItem(
//          child: Text("Setting Language"),
//          value: 1,
//        ),
//      );
//      list.add(
//        PopupMenuDivider(
//          height: 10,
//        ),
//      );
//      list.add(
//        CheckedPopupMenuItem(
//          child: Text(
//            "English",
//            style: TextStyle(color: TEXT_BLACK),
//          ),
//          value: 2,
//          checked: true,
//        ),
//      );
//      return list;
//    },
//    icon: Icon(
//      Icons.settings,
//      size: 50,
//      color: Colors.white,
//    ),
//  );


  @override
  Widget build(BuildContext context) {
    _getCurrentUser();

    // Side menu display
    Widget _selectPopup() => PopupMenuButton<int>(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Text("Reset Group Vote"),
        ),

        PopupMenuItem(
          value: 2,
          child: Text("Delete Group", style: TextStyle(color: Colors.red),),
        ),
      ],
      onCanceled: () {
        print("You have canceled the menu.");
      },

      onSelected: (value) {
        // Reset the group vote
        if (value == 1) {
          Firestore.instance.collection('groups')
              .document(widget.docId)
              .updateData({'Result': ""});
          Firestore.instance.collection('groups')
              .document(widget.docId)
              .updateData({'Preferences': []});
        }
        // Delete the group
        if (value == 2) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text(
                      "Are You Sure You Want To Delete This Group?"),
                  //content: new Text("Link to verify account has been sent to your email"),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("No"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    new FlatButton(
                      child: new Text(
                          "Yes", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        removeGroup();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
                //removeGroup();
              });
        };
      },
      icon: Icon(Icons.more_vert));



    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("New Group Vote"),
          actions: <Widget>[
            _selectPopup()
          ]
        ),
        body: Stack(
          children: <Widget>[
            _buildResultButton(),
//            _showAddUsers(),
            buildInput(),
            _showPrimaryButton(),
            _showPrefsLabel(),
//            _showFriends(),
            _showStartButton(),
            _showChat(),
//            _showAddUser(),
            _showPreferences(),
            //_buildResultButton(),
//            _showAddPreferencesButton(),
            //_showCircularProgress(),
          ],
        )
    );
  }
}