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
    return MaterialApp(
      title: "Yelp Test",
      home: Scaffold(
        appBar: AppBar(title: Text("Yelp Test")),
          body: Stack(
            children: <Widget>[
              Text("${widget.result.toString()}")
//            StreamBuilder<Friends>(
//              stream: getFriends(),
//              builder: (BuildContext c, AsyncSnapshot<Friends> data) {
//                if(data?.data == null) return Text("No Friends Found");
//                print("DATA =" + data.toString());
//                Friends friend = data.data;
//
//                return Text("${friend.friends}");
//              },
//            )
            ],
          )
        ),
      );
  }
}