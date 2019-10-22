import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class Map extends StatefulWidget {
  @override
  State<Map> createState() => MapState();
}

class MapState extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();
  var currentLocation = LocationData;
  //Future<LocationData> currentLocation;

  var location = new Location();
  CameraPosition _currentPosition;
  var latitude;
  var longitude;

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