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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lets_eat/Restaurants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:lets_eat/RestaurantInfo.dart';
import 'package:url_launcher/url_launcher.dart';

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
  var temp;
  List<String> userRecents;
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  var ratingsTable = {0:"assets/stars_small_0.png", 1:"assets/stars_small_1.png", 1.5:"assets/stars_small_1_half.png", 2:"assets/stars_small_2.png", 2.5:"assets/stars_small_2_half.png", 3:"assets/stars_small_3.png",
    3.5:"assets/stars_small_3_half.png", 4:"assets/stars_small_4.png", 4.5:"assets/stars_small_4_half.png", 5:"assets/stars_small_5.png"};
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};

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

  _launchURL(String url) async {
    String url1 = url;
    if (await canLaunch(url1)) {
      await launch(url1);
    } else {
      throw 'Could not launch $url1';
    }
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
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getStringList('recents') ?? 0;
      print("Value = " + value.toString());
      setState(() {
        if(value != 0){
          userRecents = value;
        }
        else{
          userRecents = [];
        }
      });
//      if(value != 0){
//        userRecents = value;
//      }
//      else{
//        userRecents = [];
//      }


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
              color: Colors.blueAccent,
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

  Widget showGroups() {  // Display ListView of messages
    //getCurrentUserInfo();
    String timestamp;
    String sender;
    String message;

    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 30.0, 0.0, 60.0),
        child: Center(
            child: StreamBuilder(
                stream: Stream.fromFuture(getGroups()),
                builder: (context, data) {
                  try {
                    print(widget.username.toString());
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
                                                title: Text(
                                                    '${data.data[index]
                                                        .participants
                                                        .toString()
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

    Future<List<Group>> getGroups() async {
      // Get groups list for current user
      //getCurrentUserInfo();
      List<Group> groups = [];

      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      String username = currentUser.displayName;

      await Future.delayed(const Duration(
          milliseconds: 700), () {}); // Wait for promise to return current user
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

    Widget _showRecentsLabel() {
      return new Padding(
        padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 0.0),
        child: Text("Recently Viewed:", textAlign: TextAlign.right, style: new TextStyle(fontSize: 20.0, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
      );
    }

    Future<List<Restaurants>> _loadRecents() async{
      const int CODE_OK = 200;
      const int CODE_REDIRECTION = 300;
      const int CODE_NOT_FOUND = 404;
      List<dynamic> result = [];
      for(String id in userRecents){
        String siteAddress = "https://api.yelp.com/v3/businesses/" + id; //-118.112858";

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
        result.add(r);
      }

      List<Restaurants> temp1 =[];

      for(var i in result){
        Restaurants rest1 = Restaurants.fromJson(i);
        temp1.add(rest1);
      }

      List<Restaurants> businesses = temp1;
      print(businesses);
      for (Restaurants restaurant in businesses) {
        print("Restaurant: " + restaurant.name);
      }
      return businesses;
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
                    try {
                      if (data.data?.length == 0) {
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
                                                  title: Text(
                                                      '${data.data[index]
                                                          .participants
                                                          .toString()
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
                    catch(e) {
                      return Padding(padding: const EdgeInsets.all(8.0),
                          child: Text("No Preferences Found"));
                    }
                  }
              )
          )
      );
    }

    Widget _showRecents(){
      return FutureBuilder<List<Restaurants>>(
        future: _loadRecents(),//repository.getBusinesses(),
        builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          //print("Selected Restaurant = " + snapshot.data[0].name);
          //print("It is located in " + snapshot.data[0].city + " at " + snapshot.data?.address1??"" + " " + snapshot.data?.address2??"" + " " + snapshot.data?.address3??"");
          //double miles = snapshot.data.distance * 0.000621371;  // Convert meters to miles

          Iterable markers = [];  // Holds list of Restaurant markers (Will hold only 1 marker in this case)
          Iterable _markers = Iterable.generate(snapshot.data.length, (index) {
            LatLng markerLoc = LatLng(snapshot.data[index].latitude, snapshot.data[index].longitude);
            return Marker(markerId: MarkerId("marker$index"), position: markerLoc,infoWindow: InfoWindow(
              title: snapshot.data[index].name,
            ));
          });

          markers = _markers;

          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Restaurants current = snapshot.data[index];
                    return Center(
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(padding: const EdgeInsets.all(8.0)),
                            ListTile(
                              leading: Image.network(current.imageUrl, width: 80, height: 80,),
                              title: Text('${current.name}'),
                              subtitle: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.body1,
                                    children: [
                                      TextSpan(text: '${current?.address1??""} ${current?.address2??""} ${current.city}'
                                          '\n${current.price}       '),
                                      WidgetSpan(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                            child: Image(
                                              image: AssetImage(ratingsTable[current.rating]),
                                              fit: BoxFit.fill,
                                            ),
                                          ))
                                    ],
                                  )),
                              onTap: (){
                                Route route = MaterialPageRoute(builder: (context) => RestaurantInfoPage(query:current.id, name:current.name), maintainState: true);
                                Navigator.push(context, route);
                              },
                            ),
//                                  ListTile(
//                                    title: Text('${snapshot.data.price}')
//                                  ),

                            // make buttons use the appropriate styles for cards
                            ButtonTheme.bar(
                              child: ButtonBar(
                                children: <Widget>[
                                  FlatButton(
                                      child: const Text('Unsave'),
                                      onPressed: (){
                                        showDialog(
                                          context: context,
                                          builder: (
                                              BuildContext context) {
                                            // return object of type Dialog
                                            return AlertDialog(
                                              title: new Text(
                                                  "Unsave This Restaurant?"),
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
                                                        'likedRestaurants')
                                                        .document(
                                                        temp.documentID)
                                                        .updateData(
                                                        {
                                                          'restaurantIDs': FieldValue
                                                              .arrayRemove(
                                                              [
                                                                current.id
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
                                  FlatButton(
                                    child: const Text('Directions'),
                                    onPressed: () {
                                      //_launchURL(snapshot.data.)
                                      _launchURL("google.navigation:q=${current.latitude},${current.longitude}");
                                    },
                                  ),
                                  SizedBox(
                                    width: 80.0,
                                    height: 80.0,
                                    child: FlatButton(
                                      child: Image(
                                        image: AssetImage('assets/yelpBig.png'),
                                        fit: BoxFit.contain,
                                      ),
                                      onPressed: () {
                                        _launchURL(current.url);
                                        //_launchURL(snapshot.data[index].url);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }));
        }
//              else if (widget.uid == null){
//                return Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: Text("You must be logged in to view saved restaurants"));
//              }
        else if (snapshot.hasError) {
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: Text("Something went wrong.\nPlease try again or modify your search"));
        }

        // By default, show a loading spinner
        return CircularProgressIndicator();
      }



            );
    }



    Widget _showButtonList() {
      return new Column(
        mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _showAccountManagement(),
            _showChangePreferences(),
            _showRecentsLabel(),
            Padding(padding: const EdgeInsets.all(5.0)),
            FutureBuilder<List<Restaurants>>(
                future: getRecents(),//repository.getBusinesses(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    return new Flexible(child: ListView.builder(
                            itemCount: snapshot.data.length,
                            reverse: false,
                            itemBuilder: (context, index) {
                              Restaurants current = snapshot.data[snapshot.data.length - 1 - index];
                              return Center(
                                child: Card(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(padding: const EdgeInsets.all(8.0)),
                                      ListTile(
                                        leading: Image.network(current.imageUrl, width: 80, height: 80,),
                                        title: Text('${current.name}'),
                                        subtitle: RichText(
                                            text: TextSpan(
                                              style: Theme.of(context).textTheme.body1,
                                              children: [
                                                TextSpan(text: '${current?.address1??""} ${current?.address2??""} ${current.city}'
                                                    '\n${current.price}       '),
                                                WidgetSpan(
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                      child: Image(
                                                        image: AssetImage(ratingsTable[current.rating]),
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ))
                                              ],
                                            )),
                                        onTap: (){
                                          Route route = MaterialPageRoute(builder: (context) => RestaurantInfoPage(query:current.id, name:current.name), maintainState: true);
                                          Navigator.push(context, route);
                                        },
                                      ),
//                                  ListTile(
//                                    title: Text('${snapshot.data.price}')
//                                  ),

                                      // make buttons use the appropriate styles for cards
                                      ButtonTheme.bar(
                                        child: ButtonBar(
                                          children: <Widget>[
                                            FlatButton(
                                              child: const Text('Save'),
                                              onPressed: () {
                                                RestaurantInfoPage.saveRestaurant(context, current.id, current.name);
                                                //_launchURL(snapshot.data[index].url);
                                              },
                                            ),
                                            FlatButton(
                                              child: const Text('Directions'),
                                              onPressed: () {
                                                //_launchURL(snapshot.data.)
                                                _launchURL("google.navigation:q=${current.latitude},${current.longitude}");
                                              },
                                            ),
                                            SizedBox(
                                              width: 80.0,
                                              height: 80.0,
                                              child: FlatButton(
                                                child: Image(
                                                  image: AssetImage('assets/yelpBig.png'),
                                                  fit: BoxFit.contain,
                                                ),
                                                onPressed: () {
                                                  _launchURL(current.url);
                                                  //_launchURL(snapshot.data[index].url);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),);
                  }
//              else if (widget.uid == null){
//                return Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: Text("You must be logged in to view saved restaurants"));
//              }
                  else if (snapshot.hasError) {
                    print("ERROR: " + snapshot.error.toString());
                    return CircularProgressIndicator();
                    //return Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: Text("Something went wrong.\nPlease try again or modify your search"));
                  }

                  // By default, show a loading spinner
                  return CircularProgressIndicator();
                }



            )
//            SizedBox(
//              height: 400.0,
//              child: showGroups(),
//            ),
            //_showRecents(),
          ],
        );
    }

    @override
    Widget build(BuildContext context) {
      //widget.onSignedOut();
      //getCurrentUserInfo();

      print("userid = " + widget.userId);
      String displayUName = widget.username ?? "user";
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('Hello, ' + displayUName),
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