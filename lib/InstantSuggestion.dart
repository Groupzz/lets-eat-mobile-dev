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
import 'Accounts/login_root.dart';
import 'Accounts/authentication.dart';
import 'RestaurantInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstantSuggestionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _InstantSuggestionPageState();
}

class _InstantSuggestionPageState extends State<InstantSuggestionPage> with WidgetsBindingObserver{
  //final Repository repository;
  var location = new Location();
  var ratingsTable = {0:"assets/stars_small_0.png", 1:"assets/stars_small_1.png", 1.5:"assets/stars_small_1_half.png", 2:"assets/stars_small_2.png", 2.5:"assets/stars_small_2_half.png", 3:"assets/stars_small_3.png",
  3.5:"assets/stars_small_3_half.png", 4:"assets/stars_small_4.png", 4.5:"assets/stars_small_4_half.png", 5:"assets/stars_small_5.png"};
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};
  final _random = new Random();
  Restaurants chosen = null;
  Future<Restaurants> _result;
  //final String _query;  // search query to be added under "term" of API call

  //YelpSearchPage(this._query) : super();

  //String query = query??query:"";
  //String _repository = repository;
  //YelpSearch({Key key, this.repository}) : super(key: key);

  String uid;
  String RDocID;
  List<String> userRecents;

  @override
  void initState() {
    super.initState();
    _result = findRandomRestaurant(); // only create the future once.
    // super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
    });
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
  Future<List<dynamic>> loadLikedRestaurants(List<String> ids) async{
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

    return result;
  }

  void updateRecents(String id) async{
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getStringList('recents') ?? 0;
    if(value == 0){
      prefs.setStringList('recents', [id]);
    }
    else{
      List<String> recents = value;
      print(recents.length);
      if(recents.contains(id)){

      }
      else if(recents.length >= 5){
        recents = new List.from([id])..addAll(recents.sublist(0, 4));
      }
      else {
        recents = new List.from([id])..addAll(recents);

      }
      prefs.setStringList('recents', recents);
    }
  }

  Future<Restaurants> findRandomRestaurant() async {
    String webAddress;
    var latitude;
    var longitude;
    var currentLocation = await location.getLocation();
    latitude = currentLocation.latitude;
    longitude = currentLocation.longitude;

    webAddress = "https://api.yelp.com/v3/businesses/search?&open_now=true&categories='food,restaurants,nightlife'&limit=50"; //-118.112858";
    if(!webAddress.contains("location")){
      webAddress += "&latitude=" + latitude.toString() + "&longitude=" + longitude.toString();
    }

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
    chosen = businesses[i];
    insertRestaurant(chosen);
    updateRecents(chosen.id);
    return businesses[i];

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
//      title: "Selected Restaurant",
//      home: Scaffold(
        appBar: AppBar(title: Text("Instant Suggestion"),
            actions: <Widget>[
            IconButton(
            icon: const Icon(Icons.info),
        tooltip: 'Restaurant Info',
        onPressed: () {
          if(chosen != null){
            Route route = MaterialPageRoute(builder: (context) => RestaurantInfoPage(query:chosen.id, name:chosen.name), maintainState: true);
            Navigator.push(context, route);
          }
        }
    ),]),
        body: Center(
//          child: FutureBuilder<List<Restaurants>>(
          child: FutureBuilder<Restaurants>(
            future: _result,//repository.getBusinesses(),
            builder: (context, snapshot) {
              try {
                if (snapshot.hasData) {
                  print("Selected Restaurant = " + snapshot.data.name);
                  print("It is located in " + snapshot.data.city + " at " +
                      snapshot.data?.address1 ??
                      "" + " " + snapshot.data?.address2 ??
                      "" + " " + snapshot.data?.address3 ?? "");
                  double miles = snapshot.data.distance *
                      0.000621371; // Convert meters to miles

                  Iterable markers = [
                  ]; // Holds list of Restaurant markers (Will hold only 1 marker in this case)
                  Iterable _markers = Iterable.generate(1, (index) {
                    LatLng markerLoc = LatLng(
                        snapshot.data.latitude, snapshot.data.longitude);
                    return Marker(markerId: MarkerId("marker$index"),
                        position: markerLoc,
                        infoWindow: InfoWindow(
                          title: snapshot.data.name,
                        ));
                  });

                  markers = _markers;

                  try {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return Center(
                                child: Card(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                          padding: const EdgeInsets.all(8.0)),
                                      ListTile(
                                        leading: Image.network(
                                          snapshot.data.imageUrl??"", width: 80,
                                          height: 80,
                                        ),
                                        title: Text('${snapshot.data.name}'),
                                        subtitle: RichText(
                                        text: TextSpan(
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .body1,
                                        children: [
                                        TextSpan(
                                        text: '${snapshot.data
                                            ?.address1 ??
                                        ""} ${snapshot
                                            .data?.address2 ??
                                        ""} ${snapshot.data
                                            .city??""}'
                                        '\n${snapshot.data
                                            .price??""}     ${miles
                                            .toStringAsFixed(
                                        2)} mi.  '),
                                        WidgetSpan(
                                        child: Padding(
                                        padding: const EdgeInsets
                                            .symmetric(
                                        horizontal: 2.0),
                                        child: Image(
                                          image: AssetImage(ratingsTable[snapshot.data.rating]),
                                          fit: BoxFit.fill,
                                        ),
                                        ))
                                        ],
                                        ))
                                      ),

                                      //                                  ListTile(
                                      //                                    title: Text('${snapshot.data.price}')
                                      //                                  ),

                                      // make buttons use the appropriate styles for cards
                                      ButtonTheme.bar(
                                        child: ButtonBar(
                                          children: <Widget>[
                                            FlatButton(
                                              child: const Text(
                                                  'Save Restaurant'),
                                              onPressed: () {
                                                saveRestaurant(snapshot.data.id,
                                                    snapshot.data.name);
                                                //_launchURL(snapshot.data[index].url);
                                              },
                                            ),
                                            FlatButton(
                                              child: const Text('Directions'),
                                              onPressed: () {
                                                //_launchURL(snapshot.data.)
                                                _launchURL(
                                                    "google.navigation:q=${snapshot
                                                        .data
                                                        .latitude},${snapshot
                                                        .data.longitude}");
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
                                                  _launchURL(snapshot.data.url);
                                                  //_launchURL(snapshot.data[index].url);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Container(
                                          width: 400.0,
                                          height: 400.0,
                                          child: GoogleMap(
                                            onMapCreated: _onMapCreated,
                                            markers: Set.from(markers,),
                                            mapType: MapType.normal,
                                            zoomGesturesEnabled: true,
                                            myLocationButtonEnabled: true,
                                            myLocationEnabled: true,
                                            gestureRecognizers: Set()
                                              ..add(Factory<
                                                  PanGestureRecognizer>(() =>
                                                  PanGestureRecognizer()))..add(
                                                  Factory<
                                                      ScaleGestureRecognizer>(() =>
                                                      ScaleGestureRecognizer()))..add(
                                                  Factory<
                                                      TapGestureRecognizer>(() =>
                                                      TapGestureRecognizer()))..add(
                                                  Factory<
                                                      OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer()))..add(
                                                  Factory<
                                                      VerticalDragGestureRecognizer>(
                                                          () =>
                                                          VerticalDragGestureRecognizer())),


                                            //                                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                                            //                                      new Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),
                                            //                                      ),
                                            //                                    ].toSet(),
                                            //
                                            initialCameraPosition: CameraPosition(
                                              bearing: 0,
                                              target: LatLng(
                                                  snapshot.data.latitude??0.0,
                                                  snapshot.data.longitude??0.0),
                                              zoom: 12.3,
                                            ),
                                          )

                                      )
                                    ],
                                  ),
                                ),
                              );
                            }));
                  }
                  catch(e){
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text("Error"));
                  }
                } else if (snapshot.hasError) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text("Something went wrong.\nPlease try again"));
                }

                // By default, show a loading spinner
                return CircularProgressIndicator();
              }
              catch(e){
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text("Error"));
              }
            },
          ),
        ),
      );
  }
}