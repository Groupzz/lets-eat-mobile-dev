import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lets_eat/FriendsPage.dart';
import 'package:lets_eat/GroupVotePage.dart';
import 'package:lets_eat/Accounts/UserYelpPreferences.dart';
import 'package:lets_eat/HomeSearch.dart';
import 'package:lets_eat/search.dart';
import 'package:lets_eat/Accounts/signUpPage.dart';
import 'Accounts/userAuth.dart';
import 'YelpRepository.dart';
import 'main.dart';
import 'maps.dart';
import 'Delivery.dart';
import 'Accounts/login_root.dart';
import 'Accounts/userAuth.dart';
import 'Accounts/accounts.dart';
import 'Accounts/login_root.dart';
import 'Accounts/accounts.dart';
import 'Accounts/authentication.dart';
import 'About.dart';
import 'package:lets_eat/YelpSearch.dart';
import 'Accounts/UserYelpPreferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'Restaurants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'InstantSuggestion.dart';
import 'MapRestaurant.dart';
import 'YelpSearch.dart';
import 'Accounts/LoginSignUp.dart';
import 'Accounts/signUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ShowSavedRestaurants.dart';
//import 'SearchList.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

String uid;

class _HomeState extends State<Home> with WidgetsBindingObserver{
  final searchController = TextEditingController();
  final locController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  FirebaseUser currentUser;

  Completer<GoogleMapController> _controller = Completer();
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {
    "Authorization": "Bearer $API_KEY"
  };
  var currentLocation = LocationData;

  //Location location;
  //Future<LocationData> currentLocation;

  var location = new Location();
  CameraPosition _currentPosition;
  var latitude;
  var longitude;
  var CODE_OK = 200;
  var CODE_REDIRECTION = 300;
  var CODE_NOT_FOUND = 404;
  Iterable markers = [];

  Future _getLocation() async {
    location = Location();
    var currentLocation = await location.getLocation();
    await Future.delayed(const Duration(milliseconds: 700), () {});
    setState(() {
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
      _animateToUser();
      //loading=false;
    });
  }

  Future<void> _handleNotification (Map<dynamic, dynamic> message, bool dialog) async {
    var data = message['data'] ?? message;
    String expectedAttribute = data['expectedAttribute'];
    /// [...]
  }

  @override
  void initState() {
    _getLocation();
    getBusinesses();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure();
//    print('test');
//    print('TestLatitude:$latitude');
//    print('TestLongitude:$longitude');
//    //currentLocation = location.getLocation();
//    _currentPosition = CameraPosition(
//      target: LatLng(latitude  ,  longitude),
//      zoom: 14.4746,
//    );
    super.initState();
  }

  Widget _showPrimaryButton() {
    //getCurrentUserInfo();
    return new Padding(
      padding: EdgeInsets.fromLTRB(100.0, 190.0, 90.0, 0.0),
      child: SizedBox(
        height: 40.0,
        width: 200,
        child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.lightGreen,
            child: new Text('Instant Suggestion',
                style: new TextStyle(fontSize: 16.0, color: Colors.white)),
            onPressed: () {
              Route route = MaterialPageRoute(
                  builder: (context) => InstantSuggestionPage());
              Navigator.push(context, route);
            }
        ),
      ),
    );
  }

  getBusinesses() async {
    String webAddress;
    var latitude;
    var longitude;
    var currentLocation = await location.getLocation();
    latitude = currentLocation.latitude;
    longitude = currentLocation.longitude;

    webAddress = "https://api.yelp.com/v3/businesses/search?latitude=" +
        latitude.toString() + "&longitude=" +
        longitude.toString() + "&limit=50"; //-118.112858";

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
    List results = map["businesses"];
    List<Restaurants> businesses = results.map((model) =>
        Restaurants.fromJson(model)).toList();

    Iterable _markers = Iterable.generate(50, (index) {
      Map result = results[index];
      LatLng latLngMarker = LatLng(
          businesses[index].latitude, businesses[index].longitude);

      return Marker(
        markerId: MarkerId("marker$index"),
        position: latLngMarker,
        infoWindow: InfoWindow(
            title: businesses[index].name,
            onTap: () {
              print("tapped");
              Route route = MaterialPageRoute(builder: (context) => MapRestaurantPage(result: businesses[index],));
              Navigator.push(context, route);
            }
        ),
      );
    });

    setState(() {
      markers = _markers;
    });
  }

  _onMapCreated(GoogleMapController controller){
    setState(() {
      _controller.complete(controller);
    });
  }

  _animateToUser() async {
    var pos = await location.getLocation();
    GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 15.0,
        )
    )
    );
  }


    @override
    Widget build(BuildContext context) {
      location.onLocationChanged.listen((LocationData currentLocation) {
        latitude = currentLocation.latitude;
        longitude = currentLocation.longitude;
        _currentPosition = CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 14.4746,
        );
        return LatLng(currentLocation.latitude, currentLocation.longitude);
      });
      //getCurrentUserInfo();
      Widget _selectPopup() =>
          PopupMenuButton<int>(
            itemBuilder: (context) =>
            [
              PopupMenuItem(
                value: 1,
                child: TextFormField(
                  controller: searchController,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  decoration: new InputDecoration(
                      hintText: 'Enter search term',
                      icon: new Icon(
                        Icons.search,
                        color: Colors.grey,
                      )),
                  validator: (value) =>
                  value.isEmpty
                      ? 'Username can\'t be empty'
                      : null,
                  onSaved: (value) {

                  },
                ),
              ),

              PopupMenuItem(
                value: 2,
                child: TextFormField(
                  controller: locController,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  decoration: new InputDecoration(
                      hintText: 'Current Location',
                      icon: new Icon(
                        Icons.location_on,
                        color: Colors.grey,
                      )),
                  validator: (value) =>
                  value.isEmpty
                      ? 'Username can\'t be empty'
                      : null,
                  onSaved: (value) {

                  },
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: RaisedButton(
                    elevation: 5.0,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.blue,
                    child: new Text('Search',
                        style: new TextStyle(
                            fontSize: 16.0, color: Colors.white)),
                    onPressed: () {
                      String query = "";
                      if (searchController.text.isNotEmpty) {
                        query = searchController.text;
                      }
                      if (locController.text.isNotEmpty) {
                        query += "&location=" + locController.text;
                      }
                      Route route = MaterialPageRoute(
                          builder: (context) => HomeSearchPage(query: query,));
                      Navigator.push(context, route);
                    }
                ),
              ),
            ],
            onCanceled: () {
              print("You have canceled the menu.");
            },
            onSelected: (value) {
              if (value == 1) {}
            },
            icon: Icon(Icons.search),
          );


      return Scaffold(
          key: scaffoldKey,
          drawer: new Drawer(
              child: new ListView(
                children: <Widget>[
                  new DrawerHeader(child: new Text('Menu'),),
                  new ListTile(
                    title: new Text('My Account'),
                    onTap: () {
                      Route route = MaterialPageRoute(builder: (context) =>
                          LoginRootPage(auth: new Auth(),));
                      Navigator.push(context, route);
                      //signIn(context);
//                    return UserAuth().createState().build(context);
                    },
                  ),
                  new ListTile(
                    title: new Text('Find me a restaurant'),
                    onTap: () {
                      //Repository repo = new Repository();
                      //Route route = MaterialPageRoute(builder: (context) => YelpSearch(repository: Repository()));
                      Route route = MaterialPageRoute(
                          builder: (context) => searchPage());
//                    Route route = MaterialPageRoute(builder: (context) => Repository());
                      Navigator.push(context, route);
                    },
                  ),
                  new ListTile(
                    title: new Text('Delivery'),
                    onTap: () {
                      //Repository repo = new Repository();
                      //Route route = MaterialPageRoute(builder: (context) => YelpSearch(repository: Repository()));
                      Route route = MaterialPageRoute(
                          builder: (context) => DeliveryPage());
//                    Route route = MaterialPageRoute(builder: (context) => Repository());
                      Navigator.push(context, route);
                    },
                  ),
                  new ListTile(
                    title: new Text('Group Voting'),
                    onTap: () {
                      //Repository repo = new Repository();
                      //Route route = MaterialPageRoute(builder: (context) => YelpSearch(repository: Repository()));
                      Route route = MaterialPageRoute(builder: (context) =>
                          GroupVotePage(auth: new Auth()));
//                    Route route = MaterialPageRoute(builder: (context) => Repository());
                      Navigator.push(context, route);
                    },
                  ),
                  new ListTile(
                      title: new Text("My Friends"),
                      onTap: () {
                        Route route = MaterialPageRoute(builder: (context) =>
                            FriendsPage(auth: new Auth()));
                        Navigator.push(context, route);
                      }
                  ),
                  new ListTile(
                      title: new Text("My Saved Restaurants"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ShowSavedRestaurants())
                        );
                      }
                  ),
                  new Divider(),
                  new ListTile(
                    title: new Text('About'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => About())
                      );
                    },
                  ),
                ],
              )
          ),
          appBar: AppBar(

            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: MaterialLocalizations
                      .of(context)
                      .openAppDrawerTooltip,
                );
              },
            ),
            title: const Text('Welcome!'),
            actions: <Widget>[
              _selectPopup(),
//            IconButton(
//              icon: const Icon(Icons.search),
//              tooltip: 'Show Snackbar',
//              onPressed: () {
//                Route route = MaterialPageRoute(builder: (context) => SearchList());
//                Navigator.push(context, route);
//              },
//            ),
              IconButton(
                icon: const Icon(Icons.my_location),
                tooltip: 'Nearby Restaurants',
                onPressed: () {
                  //openPage(context);
                  Route route = MaterialPageRoute(
                      builder: (context) => MapView());
                  Navigator.push(context, route);
//                Navigator.push(context, Maps());
                  //runApp(Server());
                },
              ),
            ],
          ),
          body: latitude == null || longitude == null
              ? new Stack(
            children: [
              Positioned.fill( //
                child: Image(
                  image: AssetImage("assets/mobileHome2.JPG"),
                  fit: BoxFit.fill,
                ),
              ),
//              _showPrimaryButton(),
//              new Container(
//
//                  child: SizedBox(
//
//                    child: Padding(
//                      padding: EdgeInsets.fromLTRB(60.0, 250.0, 60.0, 50.0),
//                      child: GoogleMap(
//                        markers: Set.from(
//                          markers,
//                        ),
//                        mapType: MapType.normal,
//                        myLocationButtonEnabled: true,
//                        myLocationEnabled: true,
//                        onMapCreated: _onMapCreated,
//                        initialCameraPosition: CameraPosition(
//                          target: LatLng(latitude ?? 0, longitude ?? 0),
//                          zoom: 5.0,
//                        ),
//                      ),
//                    ),
//                  )),
//            _showPrimaryButton(),
            ],
          )
              : new Stack(
            children: <Widget>[
              Positioned.fill( //
                child: Image(
                  image: AssetImage("assets/mobileHome2.JPG"),
                  fit: BoxFit.fill,
                ),
              ),
              _showPrimaryButton(),
              new Container(

                  child: SizedBox(

                    child: Padding(
                      padding: EdgeInsets.fromLTRB(60.0, 250.0, 60.0, 50.0),
                      child: GoogleMap(
                        markers: Set.from(
                          markers,
                        ),
                        mapType: MapType.normal,
                        indoorViewEnabled: true,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(latitude, longitude),
                          zoom: 15.0,
                        ),
                      ),
                    ),
                  )),
//
            ],
          )
//      body: const Center(
//        child: Text(
//          'Welcome to Let\'s Eat!',
//          style: TextStyle(fontSize: 24),
//        ),
//      ),
      );
    }
  }
