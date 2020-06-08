import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'package:lets_eat/About.dart';
import 'package:location/location.dart';
import 'maps.dart';
import 'dart:math';
import 'Restaurants.dart';
import 'YelpRepository.dart';
import 'Accounts/authentication.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Accounts/login_root.dart';
import 'RestaurantInfo.dart';
import 'Accounts/userAuth.dart';
import 'home.dart';
import 'About.dart';
import 'main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'Home.dart';

class ShowSavedRestaurants extends StatefulWidget {
  ShowSavedRestaurants({this.uid, this.auth});

  final BaseAuth auth;
  final String uid;

  @override
  State<StatefulWidget> createState() => new _ShowSavedRestaurantsState();
}

class _ShowSavedRestaurantsState extends State<ShowSavedRestaurants> {
  //final Repository repository;
  var location = new Location();
  var ratingsTable = {0:"assets/stars_small_0.png", 1:"assets/stars_small_1.png", 1.5:"assets/stars_small_1_half.png", 2:"assets/stars_small_2.png", 2.5:"assets/stars_small_2_half.png", 3:"assets/stars_small_3.png",
    3.5:"assets/stars_small_3_half.png", 4:"assets/stars_small_4.png", 4.5:"assets/stars_small_4_half.png", 5:"assets/stars_small_5.png"};
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};
  final _random = new Random();
  //final String _query;  // search query to be added under "term" of API call

  //ShowSavedRestaurants(this._query) : super();

  //String query = query??query:"";
  //String _repository = repository;
  //YelpSearch({Key key, this.repository}) : super(key: key);

  String uid;
  String RDocID;
  var temp;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;
  bool _isEmailVerified = false;

  @override
  void initState(){// store info for current user
    super.initState();
    _checkEmailVerification();
  }

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
              "Please verify your account in the link sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
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

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("You Must Sign In First"),
          content: new Text(
              "You must be signed in to view your saved restaurants"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Sign In "),
              onPressed: () {
                Route route = MaterialPageRoute(builder: (context) =>
                    LoginRootPage(auth: new Auth(),));
                Navigator.push(context, route);
              },
            ),
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

  void _checkEmailVerification() async {
    user = await FirebaseAuth.instance.currentUser();
    if(user == null){
      _showSignInDialog();
    }
    else {
      Future<FirebaseUser>currentUser = widget.auth.getCurrentUser();
      _isEmailVerified = await widget.auth.isEmailVerified();

      if (!_isEmailVerified) {
        _showVerifyEmailDialog();
      }
    }
  }

  _launchURL(String url) async {
    String url1 = url;
    if (await canLaunch(url1)) {
      await launch(url1);
    } else {
      throw 'Could not launch $url1';
    }
  }

  /// Call this method with a list of business id's
  /// The Yelp API will look up every ID in the list, and the API's response for each is added to the results list
  /// The results llst is returned, which will need to be parsed by a FutureBuilder
  Future<List<Restaurants>> loadLikedRestaurants() async{
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();//auth.currentUser();
    uid = user.uid;
    //var temp;

    ///query gets string of restaurant ids from uid
    await Firestore.instance
        .collection('likedRestaurants')
        .where('id', isEqualTo: uid)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => temp = f);});

    List<String> ids = new List<String>.from(temp.data['restaurantIDs']);


    List<dynamic> result = [];
    for(String id in ids){
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

  Future<Restaurants> findRandomRestaurant() async {
    String webAddress;
    var latitude;
    var longitude;
    var currentLocation = await location.getLocation();
    latitude = currentLocation.latitude;
    longitude = currentLocation.longitude;

    webAddress = "https://api.yelp.com/v3/businesses/search?term=" + "tacos" + "&limit=50"; //-118.112858";
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
    return businesses[i];

  }

  void showError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Something Went Wrong!"),
          content: new Text("Please try again or modify your search parameters"),
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

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: AppBar(title: Text("Saved Restaurants")),
        body: Center(
//          child: FutureBuilder<List<Restaurants>>(
          child: FutureBuilder<List<Restaurants>>(
            future: loadLikedRestaurants(),//repository.getBusinesses(),
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
            },
          ),
        ),
      );
  }
}