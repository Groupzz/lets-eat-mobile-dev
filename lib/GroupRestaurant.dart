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

class GroupRestaurantPage extends StatefulWidget {
  GroupRestaurantPage({this.result});

  final dynamic result;

  @override
  State<StatefulWidget> createState() => new _GroupRestaurantPageState();
}

class _GroupRestaurantPageState extends State<GroupRestaurantPage> {
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

    return MaterialApp(
      title: "Yelp Test",
      home: Scaffold(
        appBar: AppBar(title: Text("Group Vote Result")),
        body: Center(
        child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(8.0)),
            ListTile(
                leading: Image.network(widget.result['image_url'], width: 80, height: 80,),
                title: Text('${widget.result['name']}'),
                subtitle: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.body1,
                      children: [
                        TextSpan(text: '${loc['display_address'].toString().substring(1, loc['display_address'].toString().length - 1)??""}'
                            '\n${widget.result['price']}           ${widget.result['rating']}'),
                        WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Icon(Icons.star),
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
                      //saveRestaurant(snapshot.data.id,snapshot.data.name);
                      //_launchURL(snapshot.data[index].url);
                    },
                  ),
                  FlatButton(
                    child: const Text('WEBSITE'),
                    onPressed: () {
                      _launchURL(widget.result['url']);
                      //_launchURL(snapshot.data[index].url);
                    },
                  ),
                  FlatButton(
                    child: const Text('NAVIGATE'),
                    onPressed: () {
                      //_launchURL(snapshot.data.)
                    },
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
        ),
      );
  }
}