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
import 'Accounts/userAuth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'About.dart';
import 'main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

class LikedPage extends StatefulWidget {
  LikedPage({this.results});

  final List<dynamic> results;

  @override
  State<StatefulWidget> createState() => new _LikedPageState();
}

class _LikedPageState extends State<LikedPage> {
  //final Repository repository;
  var location = new Location();
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



  void saveRestaurant(String restaurantID,String restaurantName) async{
    bool success = true;
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();//auth.currentUser();
    uid = user.uid;
    try {
      // Check if provided restaurant is already saved in database
      Firestore.instance
          .collection('likedRestaurants')
          .where(
          'restaurantIDs', isEqualTo: restaurantID)
          .snapshots()
          .listen(

              (data) => data.documents.length == 0
          // If so, update user's restaurant array w/ new restaurant
              ? Firestore.instance
              .collection('users')
              .where(
              'id', isEqualTo: uid // Get current user id
          )
              .snapshots()
              .listen(
            // Update Restaurants collection that contains current user ID
                  (data)=> saveRestaurantDB(data,restaurantID,restaurantName)
          )
          // If not, show error message
              : showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("Restaurant is already saved"),
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
    }
  }

  Future<void> saveRestaurantDB(QuerySnapshot snap,String rID,String rName) async{

    Firestore.instance
        .collection('likedRestaurants')
        .where(
        'id', isEqualTo: uid)
        .snapshots()
        .listen(
            (data) => RDocID = data.documents[0].documentID
    );
    Firestore.instance
        .collection('likedRestaurants')
        .document(RDocID)
        .updateData(
        {'restaurantIDs':FieldValue.arrayUnion([rID])}
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

  /// Call this method with a list of business id's
  /// The Yelp API will look up every ID in the list, and the API's response for each is added to the results list
  /// The results llst is returned, which will need to be parsed by a FutureBuilder
  Future<List<dynamic>> loadLikedRestaurants() async{
    FirebaseUser current = await FirebaseAuth.instance.currentUser();
    //Firestore.instance.collection('likedRestaurants').where('id', isEqualTo: current.)
    List<dynamic> result = [];
    List<String> ids = [];
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

    return result;
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Search Results",
      home: Scaffold(
        appBar: AppBar(title: Text("Search Results")),
        body: Stack(
            children: <Widget>[
              FutureBuilder<List<Restaurants>>(
                future: loadLikedRestaurants(),
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
                              double miles = snapshot.data[index].distance * 0.000621371;  // Convert meters to miles
                              return Center(
                                child: Card(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(padding: const EdgeInsets.all(8.0)),
                                      ListTile(
                                          leading: Image.network(snapshot.data[index].imageUrl, width: 80, height: 80,),
                                          title: Text('${snapshot.data[index].name}'),
                                          subtitle: RichText(
                                              text: TextSpan(
                                                style: Theme.of(context).textTheme.body1,
                                                children: [
                                                  TextSpan(text: '${snapshot.data[index]?.address1??""} ${snapshot.data[index]?.address2??""} ${snapshot.data[index].city}'
                                                      '\n${snapshot.data[index].price}        ${miles.toStringAsFixed(2)} mi.           ${snapshot.data[index].rating}'),
                                                  WidgetSpan(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                        child: Icon(Icons.star),
                                                      ))
                                                ],
                                              ))),
                                      ButtonTheme.bar(
                                        // make buttons use the appropriate styles for cards
                                        child: ButtonBar(
                                          children: <Widget>[
                                            FlatButton(
                                              child: const Text('WEBSITE'),
                                              onPressed: () {
                                                _launchURL(snapshot.data[index].url);
                                              },
                                            ),
                                            FlatButton(
                                              child: const Text('NAVIGATE'),
                                              onPressed: () {
                                                _launchURL("google.navigation:q=${snapshot.data[index].latitude},${snapshot.data[index].longitude}");
                                              },
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
                    return Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: Text("${snapshot.error}"));
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