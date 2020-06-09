import 'package:flutter/material.dart';
import 'YelpSearch.dart';
import 'YelpRepository.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
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
import 'Accounts/userAuth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'About.dart';
import 'main.dart';
import 'package:flutter/foundation.dart';
import 'Accounts/login_root.dart';
import 'Accounts/authentication.dart';
import 'RestaurantInfo.dart';

class DeliveryPage extends StatefulWidget
{
  @override
  DeliveryPageState createState() {
    return DeliveryPageState();
  }
}

class DeliveryPageState extends State<DeliveryPage> {
  var location = new Location();
  var ratingsTable = {0:"assets/stars_small_0.png", 1:"assets/stars_small_1.png", 1.5:"assets/stars_small_1_half.png", 2:"assets/stars_small_2.png", 2.5:"assets/stars_small_2_half.png", 3:"assets/stars_small_3.png",
    3.5:"assets/stars_small_3_half.png", 4:"assets/stars_small_4.png", 4.5:"assets/stars_small_4_half.png", 5:"assets/stars_small_5.png"};
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};
  final _random = new Random();
  //final String _query;  // search query to be added under "term" of API call

  //YelpSearchPage(this._query) : super();

  //String query = query??query:"";
  //String _repository = repository;
  //YelpSearch({Key key, this.repository}) : super(key: key);

  String uid;
  String RDocID;

  _launchURL(String url) async {
    String url1 = url;
    if (await canLaunch(url1)) {
      await launch(url1);
    } else {
      throw 'Could not launch $url1';
    }
  }
  Future<List<String>> getSavedRestaurants() async{
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();//auth.currentUser();
    uid = user.uid;
    var temp;
    await Firestore.instance
        .collection('likedRestaurants')
        .where('id', isEqualTo: uid)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => temp = f);});

    List<String> result = new List<String>.from(temp.data['restaurantIDs']);
    return result;
  }

  Future<List<Restaurants>> search() async {

    String webAddress;
    var latitude;
    var longitude;
    var currentLocation = await location.getLocation();
    latitude = currentLocation.latitude;
    longitude = currentLocation.longitude;

    webAddress = "https://api.yelp.com/v3/transactions/delivery/search?"; //-118.112858";
    webAddress += "latitude=" + latitude.toString() + "&longitude=" + longitude.toString() + "&limit=50";


    http.Response response = await http.get(webAddress, headers: AUTH_HEADER).catchError((resp) {});

    // Error handling
    if (response == null || response.statusCode < CODE_OK || response.statusCode >= CODE_REDIRECTION) {
      return Future.error(response.body);
    }

    Map<String, dynamic> map = json.decode(response.body);

    Iterable jsonList = map["businesses"];
    List<Restaurants> businesses = jsonList.map((model) => Restaurants.fromJson(model)).toList();

    debugPrint(jsonList.toString());

    return businesses;
  }

  void saveRestaurant(String restaurantID,String restaurantName) async {
    bool success = true;
    final FirebaseUser user = await FirebaseAuth.instance
        .currentUser(); //auth.currentUser();
    if (user == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("You Must Sign In First"),
            content: new Text(
                "You must be signed in to save restaurants"),
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
                },
              ),
            ],
          );
        },
      );
    }
    else {
      try {
        uid = user.uid;
        // Check if provided restaurant is already saved in database
        Firestore.instance
            .collection('likedRestaurants')
            .where(
            'restaurantIDs', isEqualTo: restaurantID)
            .snapshots()
            .listen(

                (data) =>
            data.documents.length == 0
            // If so, update user's restaurant array w/ new restaurant
                ? Firestore.instance
                .collection('users')
                .where(
                'id', isEqualTo: uid // Get current user id
            )
                .snapshots()
                .listen(
              // Update Restaurants collection that contains current user ID
                    (data) =>
                    saveRestaurantDB(data, restaurantID, restaurantName)
            )
            // If not, show error message
                : showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text("Restaurant is already saved"),
                  //content: new Text("We didn't find a user with that username.  Please make sure the username is correct"),
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
      catch (e) {}
    }
  }

  Future<void> saveRestaurantDB(QuerySnapshot snap,String rID,String rName) async{

    Firestore.instance
        .collection('likedRestaurants')
        .where(
        'id', isEqualTo: uid)
        .snapshots()
        .listen(
            (data) {
          Firestore.instance
              .collection('likedRestaurants')
              .document(data.documents[0].documentID)
              .updateData(
              {'restaurantIDs':FieldValue.arrayUnion([rID])}
          );
        }
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Restaurant Saved!"),
          content: new Text("${rName} has been added to your saved Restaurants"),
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

  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Search Results",
      home: Scaffold(
        appBar: AppBar(title: Text("Nearby Delivery"),),
        body: Stack(
            children: <Widget>[
              FutureBuilder<List<Restaurants>>(
                future: search(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
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

                              return Center(
                                child: Card(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(padding: const EdgeInsets.all(8.0)),
                                      ListTile(
                                          leading: Image.network(snapshot.data[index].imageUrl??"", width: 80, height: 80,),
                                          title: Text('${snapshot.data[index].name}'),
                                          subtitle: RichText(
                                              text: TextSpan(
                                                style: Theme.of(context).textTheme.body1,
                                                children: [
                                                  TextSpan(text: '${snapshot.data[index]?.address1??""} ${snapshot.data[index]?.address2??""} ${snapshot.data[index].city}'
                                                      '\n${snapshot.data[index].price??""}  '),
                                                  WidgetSpan(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                        child: Image(
                                                          image: AssetImage(ratingsTable[snapshot.data[index].rating]),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ))
                                                ],
                                              )),
                                          onTap: (){
                                            Route route = MaterialPageRoute(builder: (context) => RestaurantInfoPage(query:snapshot.data[index].id, name:snapshot.data[index].name), maintainState: true);
                                            Navigator.push(context, route);
                                          }
                                      ),
                                      ButtonTheme.bar(
                                        // make buttons use the appropriate styles for cards
                                        child: ButtonBar(
                                          children: <Widget>[
                                            FlatButton(
                                              child: const Text('Save Restaurant'),
                                              onPressed: () {
                                                saveRestaurant(snapshot.data[index].id,snapshot.data[index].name);
                                                //_launchURL(snapshot.data[index].url);
                                              },
                                            ),
                                            FlatButton(
                                              child: const Text('Directions'),
                                              onPressed: () {
                                                _launchURL("google.navigation:q=${snapshot.data[index].latitude},${snapshot.data[index].longitude}");
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
                                                  _launchURL(snapshot.data[index].url);
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
                  } else if (snapshot.hasError) {
                    return Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: Text("Something went wrong.\nPlease try again or modify your search"));
                  }

                  // By default, show a loading spinner
                  return CircularProgressIndicator();
                },
              ),

            ]
        ),
      ),
    );
  }
}