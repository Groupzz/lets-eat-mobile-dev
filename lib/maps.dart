import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'Restaurants.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lets_eat/GroupRestaurant.dart';
import 'package:url_launcher/url_launcher.dart';

class MapView extends StatefulWidget {
  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};
  var currentLocation = LocationData;
  //Future<LocationData> currentLocation;

  var location = new Location();
  CameraPosition _currentPosition;
  var latitude;
  var longitude;
  var CODE_OK = 200;
  var CODE_REDIRECTION = 300;
  var CODE_NOT_FOUND = 404;
  Iterable markers = [];

  _launchURL(String url) async {
    String url1 = url;
   if (await canLaunch(url1)) {
     await launch(url1);
   } else {
     throw 'Could not launch $url1';
   }
  }

//  Future _getLocation() async {
//    try {
//      location.onLocationChanged().listen((LocationData currentLocation) {
//        latitude = currentLocation.latitude;
//        longitude = currentLocation.longitude;
////        print('Latitude:$latitude');
////        print('Longitude:$longitude');
//        _currentPosition = CameraPosition(
//          target: LatLng(latitude  ,  longitude),
//          zoom: 14.4746,
//        );
//        print('Latitude:$latitude');
//        print('Longitude:$longitude');
//        return LatLng(currentLocation.latitude, currentLocation.longitude);
//      });
//    } catch (e) {
//      print('ERROR:$e');
//      currentLocation = null;
//    }
  Future _getLocation() async {
    final location = Location();
    var currentLocation = await location.getLocation();
    setState(() {
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
      //loading=false;
    });

  }

  @override
  void initState() {
    _getLocation();
    getBusinesses();
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
    List results = map["businesses"];
    List<Restaurants> businesses = results.map((model) =>
        Restaurants.fromJson(model)).toList();

    Iterable _markers = Iterable.generate(50, (index) {
      Map result = results[index];
      LatLng latLngMarker = LatLng(businesses[index].latitude, businesses[index].longitude);

      return Marker(
          markerId: MarkerId("marker$index"),
          position: latLngMarker,
          infoWindow: InfoWindow(
            title: businesses[index].name,
            onTap: () {
              print("tapped");
              _launchURL(businesses[index].url);
            }
          ),
      );
    });

    setState(() {
      markers = _markers;
    });


  }


  @override
  Widget build(BuildContext context) {
    location.onLocationChanged().listen((LocationData currentLocation) {
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
//        print('Latitude:$latitude');
//        print('Longitude:$longitude');
      _currentPosition = CameraPosition(
        target: LatLng(latitude  ,  longitude),
        zoom: 14.4746,
      );
      print('Latitude:$latitude');
      print('Longitude:$longitude');
      return LatLng(currentLocation.latitude, currentLocation.longitude);
    });
//    print('TestLatitude:$latitude');
//    print('TestLongitude:$longitude');
//    var latlong = location.getLocation().toString();
//    print('latTest:$latlong');
//    latitude = latlong[0];
//    longitude = latlong[1];
//    LatLng loc = new LatLng(latitude, longitude);

    return new Scaffold(
      body: latitude == null || longitude == null
          ? Container()
          : GoogleMap(
        markers: Set.from(
          markers,
        ),
        mapType: MapType.hybrid,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15.0,
        ),
      ),
//      GoogleMap(
//        mapType: MapType.normal,
//        initialCameraPosition:CameraPosition(
//          target: LatLng(latitude  ,  longitude),
//          zoom: 14.4746,
//        ),
//        zoomGesturesEnabled: true,
//        myLocationButtonEnabled: true,
//        rotateGesturesEnabled: true,
//        tiltGesturesEnabled: true,
//        onMapCreated: (GoogleMapController controller) {
//          _controller.complete(controller);
//        },
//      ),

    );
  }


}


//import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:location/location.dart';
//
//GoogleMapController mapController;
//var currentLocation = LocationData;
//Location location = Location();
//var lat = 33.783022;
//var lon = -118.112858;
//var center = LatLng(lat, lon);
////final LatLng _center = const LatLng(45.521563, -122.677433);
//
//void _onMapCreated(GoogleMapController controller) {
//  mapController = controller;
//}
//
//class Maps extends MaterialPageRoute<Null>{
//
//  Maps() : super(builder: (BuildContext ctx) {
//  return Scaffold(
//    appBar: AppBar(
//      title: Text('Maps Sample App'),
//      backgroundColor: Colors.lightBlue,
//    ),
//    body: GoogleMap(
//      onMapCreated: _onMapCreated,
//      initialCameraPosition: CameraPosition(
//        target: center,
//        zoom: 11.0,
//      ),
//    ),
//  );
//  });
//}