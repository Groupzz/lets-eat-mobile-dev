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

class RestaurantInfoPage extends StatefulWidget {
  RestaurantInfoPage({this.query});

  final String query;

  @override
  State<StatefulWidget> createState() => new _RestaurantInfoPageState();
}


class _RestaurantInfoPageState extends State<RestaurantInfoPage> {
  @override
  Widget build(BuildContext context) {

  }
}