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
import 'RestaurantInfo.dart';

class GroupRestaurantPage extends StatefulWidget {
  GroupRestaurantPage({this.result});

  final dynamic result;

  @override
  State<StatefulWidget> createState() => new _GroupRestaurantPageState();
}

class _GroupRestaurantPageState extends State<GroupRestaurantPage> with WidgetsBindingObserver{
  //final Repository repository;
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


  @override
  Widget build(BuildContext context) {

    Map<String, dynamic> loc = widget.result['location'];
    //print("City = " + loc['city']);

    Map<String, dynamic> coords = widget.result['coordinates'];


    Iterable markers = [];  // Holds list of Restaurant markers (Will hold only 1 marker in this case)
    Iterable _markers = Iterable.generate(1, (index) {
      LatLng markerLoc = LatLng(coords['latitude'], coords['longitude']);
      return Marker(markerId: MarkerId("marker$index"), position: markerLoc,infoWindow: InfoWindow(
        title: widget.result['name'],
      ));
    });

    markers = _markers;

    return new Scaffold(
        appBar: AppBar(title: Text(widget.result['name']),
            actions: <Widget>[
            IconButton(
            icon: const Icon(Icons.info),
        tooltip: 'Restaurant Info',
        onPressed: () {
            Route route = MaterialPageRoute(builder: (context) => RestaurantInfoPage(query:widget.result['id'], name:widget.result['name']), maintainState: true);
            Navigator.push(context, route);
        }
    )],),
        body: Center(
        child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(8.0)),
            ListTile(
                leading: Image.network(widget.result['image_url']??"", width: 80, height: 80,),
                title: Text('${widget.result['name']}'),
                subtitle: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.body1,
                      children: [
                        TextSpan(text: '${loc['display_address'].toString().substring(1, loc['display_address'].toString().length - 1)??""}'
                            '\n${widget.result['price']??""}       '),
                        WidgetSpan(
                            child: Image(
                              image: AssetImage(ratingsTable[widget.result['rating']]),
                              fit: BoxFit.fill,
                            ))
                      ],
                    ))
            ),
//                                    ListTile(
//                                      title: Text('${snapshot.data.price}')
//                                    ),

            // make buttons use the appropriate styles for cards
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('Save Restaurant'),
                    onPressed: () {
                      saveRestaurant(widget.result['id'], widget.result['name']);
                      //_launchURL(snapshot.data[index].url);
                    },
                  ),
                  FlatButton(
                    child: const Text('Directions'),
                    onPressed: () {
                      _launchURL("google.navigation:q=${coords['latitude']},${coords['longitude']}");
                      //_launchURL(snapshot.data.)
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
                        _launchURL(widget.result['url']);
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
                  markers: Set.from(markers, ),
                  mapType: MapType.normal,
                  zoomGesturesEnabled: true,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  gestureRecognizers: Set()
                    ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
                    ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
                    ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
                    ..add(Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer()))
                    ..add(Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer())),


  //                                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
  //                                      new Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),
  //                                      ),
  //                                    ].toSet(),
  //
                  initialCameraPosition: CameraPosition(
                    bearing: 0,
                    target: LatLng(coords['latitude'], coords['longitude']),
                    zoom: 12.3,
                  ),
                )

          )
          ],
      ),
    ),
    )
    );
  }
}