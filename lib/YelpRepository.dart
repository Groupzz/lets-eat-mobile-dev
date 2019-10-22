import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'Restaurants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class Repository {
  static final Repository _repo = new Repository._internal();
  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};

  var currentLocation = LocationData;
  var location = new Location();
  var latitude;
  var longitude;

  Future _getLocation() async {
    final location = Location();
    var currentLocation = await location.getLocation();
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
      //loading=false;

  }

  static Repository get() {
    return _repo;
  }

  Repository._internal();

  // Get best restaurants near devices current location
  Future<List<Restaurants>> getBusinesses() async {

    _getLocation();

    location.onLocationChanged().listen((LocationData currentLocation) {
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
//        print('Latitude:$latitude');
//        print('Longitude:$longitude');

      return LatLng(currentLocation.latitude, currentLocation.longitude);
    });

    String webAddress;// = "https://api.yelp.com/v3/businesses/search?latitude=33.783022&longitude=-118.112858";
    latitude == null || longitude == null
        ? webAddress = "https://api.yelp.com/v3/businesses/search?latitude=33.783022&longitude=-118.112858"
        : webAddress = "https://api.yelp.com/v3/businesses/search?latitude="+latitude.toString()+"&longitude=" + longitude.toString();//-118.112858";

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
}