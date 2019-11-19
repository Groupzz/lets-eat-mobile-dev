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
import 'userAuth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'About.dart';
import 'main.dart';

class YelpSearch extends StatelessWidget {
  //final Repository repository;
  var location = new Location();
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};
  final _random = new Random();
  final String _query;  // search query to be added under "term" of API call

  YelpSearch(this._query) : super();

  //String query = query??query:"";
  //String _repository = repository;
  //YelpSearch({Key key, this.repository}) : super(key: key);

  _launchURL(String url) async {
    String url1 = url;
    if (await canLaunch(url1)) {
      await launch(url1);
    } else {
      throw 'Could not launch $url1';
    }
  }

  Future<Restaurants> findRandomRestaurant() async {
    String webAddress;
    var latitude;
    var longitude;
    var currentLocation = await location.getLocation();
    latitude = currentLocation.latitude;
    longitude = currentLocation.longitude;

    webAddress = "https://api.yelp.com/v3/businesses/search?term=" + _query + "&latitude=" + latitude.toString() + "&longitude=" + longitude.toString() + "&limit=50&radius=40000"; //-118.112858";

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

  @override
  Widget build(BuildContext context) {
    print(_query);
    return MaterialApp(
      title: "Yelp Test",
      home: Scaffold(
        appBar: AppBar(title: Text("Yelp Test")),
        body: Center(
//          child: FutureBuilder<List<Restaurants>>(
          child: FutureBuilder<Restaurants>(
            future: findRandomRestaurant(),//repository.getBusinesses(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print("Selected Restaurant = " + snapshot.data.name);
                print("It is located in " + snapshot.data.city + " at " + snapshot.data?.address1??"" + " " + snapshot.data?.address2??"" + " " + snapshot.data?.address3??"");
                double miles = snapshot.data.distance * 0.000621371;  // Convert meters to miles

                Iterable markers = [];  // Holds list of Restaurant markers (Will hold only 1 marker in this case)
                Iterable _markers = Iterable.generate(1, (index) {
                  LatLng markerLoc = LatLng(snapshot.data.latitude, snapshot.data.longitude);
                  return Marker(markerId: MarkerId("marker$index"), position: markerLoc,infoWindow: InfoWindow(
                    title: snapshot.data.name,
                  ));
                });

                markers = _markers;

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
                                  Padding(padding: const EdgeInsets.all(8.0)),
                                  ListTile(
                                    leading: Image.network(snapshot.data.imageUrl, width: 80, height: 80,),
                                    title: Text('${snapshot.data.name}'),
                                    subtitle: RichText(
                                        text: TextSpan(
                                            style: Theme.of(context).textTheme.body1,
                                            children: [
                                              TextSpan(text: '${snapshot.data?.address1??""} ${snapshot.data?.address2??""} ${snapshot.data.city}'
                                        '\n${snapshot.data.price}        ${miles.toStringAsFixed(2)} mi.           ${snapshot.data.rating}'),
                                              WidgetSpan(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                  child: Icon(Icons.star),
                                              ))
                                    ],
                                  ))),
//                                  ListTile(
//                                    title: Text('${snapshot.data.price}')
//                                  ),
                                  ButtonTheme.bar(
                                    // make buttons use the appropriate styles for cards
                                    child: ButtonBar(
                                      children: <Widget>[
                                        FlatButton(
                                          child: const Text('WEBSITE'),
                                          onPressed: () {
                                            _launchURL(snapshot.data.url);
                                            //_launchURL(snapshot.data[index].url);
                                          },
                                        ),
                                        FlatButton(
                                          child: const Text('NAVIGATE'),
                                          onPressed: () {
                                            //todo: launch using google/apple maps
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 400.0,
                                    height: 400.0,
                                  child: GoogleMap(
                                    markers: Set.from(markers, ),
                                    mapType: MapType.normal,
                                    myLocationButtonEnabled: true,
                                    myLocationEnabled: true,
                                    initialCameraPosition: CameraPosition(
                                      bearing: 0,
                                      target: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                                      zoom: 12.3,
                                    ),
                                  )
                                  )
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
        ),
      ),
    );
  }
}