import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'Restaurants.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ParsedResponse<T> {
  ParsedResponse(this.statusCode, this.body);

  final int statusCode;
  final T body;

  bool isSuccess() {
    return statusCode >= 200 && statusCode < 300;
  }
}

const int CODE_OK = 200;
const int CODE_REDIRECTION = 300;
const int CODE_NOT_FOUND = 404;
final _random = new Random();

class Repository extends StatefulWidget {
  Repository();
  @override
  _RepositoryState createState() => _RepositoryState();
}

class _RepositoryState extends State<Repository>
{

  _RepositoryState();
  @override
  void initState()
  {
    //_getLocation();
    super.initState();
  }


  static final _RepositoryState _repo = new _RepositoryState._internal();
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};

  var currentLocation = LocationData;
  var location = new Location();
//  var latitude;
//  var longitude;
  CameraPosition _currentPosition;

//  Future _getLocation() async {
//    final location = Location();
//    var currentLocation = await location.getLocation();
//    setState(() {
//      latitude = currentLocation.latitude;
//      longitude = currentLocation.longitude;
//      //loading=false;
//    });
//
//  }

  Future<List<Restaurants>> getBusinesses() async {
    String webAddress;
    var latitude;
    var longitude;
    var currentLocation = await location.getLocation();
    latitude = currentLocation.latitude;
    longitude = currentLocation.longitude;

    webAddress = "https://api.yelp.com/v3/businesses/search?latitude=" + latitude.toString() + "&longitude=" + longitude.toString(); //-118.112858";

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

    return businesses;

  }


  Future<Restaurants> findRandomRestaurant() async {
    String webAddress;
    var latitude;
    var longitude;
    var currentLocation = await location.getLocation();
    latitude = currentLocation.latitude;
    longitude = currentLocation.longitude;

    webAddress = "https://api.yelp.com/v3/businesses/search?latitude=" + latitude.toString() + "&longitude=" + longitude.toString(); //-118.112858";

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

    int min = 0;
    int max = businesses.length;
    int i = min + _random.nextInt(max - min);
    return businesses[i];

  }

//  Future<Restaurants> getBusinesses() async {
//    String webAddress;
//    var latitude;
//    var longitude;
//    var currentLocation = await location.getLocation();
//    latitude = currentLocation.latitude;
//    longitude = currentLocation.longitude;
//
//    webAddress = "https://api.yelp.com/v3/businesses/search?latitude=" + latitude.toString() + "&longitude=" + longitude.toString(); //-118.112858";
//
//    //webAddress = "https://api.yelp.com/v3/businesses/search?latitude=33.783022&longitude=-118.112858";
//    print("latitude = " + latitude.toString() + "; longitude = " +
//        longitude.toString());
//    http.Response response;
//    Map<String, dynamic> map;
//    response =
//    await http.get(webAddress, headers: AUTH_HEADER).catchError((resp) {});
//
//    //Map<String, dynamic> map;
//    // Error handling
//    //    response == null
//    //    ? response = await http.get(webAddress, headers: AUTH_HEADER).catchError((resp) {})
//    //    : map = json.decode(response.body);
//    if (response == null || response.statusCode < CODE_OK ||
//        response.statusCode >= CODE_REDIRECTION) {
//      return Future.error(response.body);
//    }
//
//    //    Map<String, dynamic> map = json.decode(response.body);
//    map = json.decode(response.body);
//    Iterable jsonList = map["businesses"];
//    List<Restaurants> businesses = jsonList.map((model) =>
//        Restaurants.fromJson(model)).toList();
//    print(jsonList.toString());
//    for (Restaurants restaurant in businesses) {
//      print("Restaurant: " + restaurant.name);
//    }
//    //print("Businesses: " + businesses.toString());
//
//    return businesses[0];
//  }


  static _RepositoryState get() {
    return _repo;
  }
  _RepositoryState._internal();


  @override
  Widget build(BuildContext context) {
//    location.onLocationChanged().listen((LocationData currentLocation) {
//      latitude = currentLocation.latitude;
//      longitude = currentLocation.longitude;
////        print('Latitude:$latitude');
////        print('Longitude:$longitude');
//      _currentPosition = CameraPosition(
//        target: LatLng(latitude  ,  longitude),
//        zoom: 14.4746,
//      );
//      print('Latitude:$latitude');
//      print('Longitude:$longitude');
//      return LatLng(currentLocation.latitude, currentLocation.longitude);
//    });
////    latitude == null || longitude == null
////        ? Container()
////        :;
  }
}