import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

GoogleMapController mapController;
var currentLocation = LocationData;
var location = new Location();
var lat = 33.783022;
var lon = -118.112858;
var center = LatLng(lat, lon);
//final LatLng _center = const LatLng(45.521563, -122.677433);

void _onMapCreated(GoogleMapController controller) {
  mapController = controller;
}

class Maps extends MaterialPageRoute<Null>{

  Maps() : super(builder: (BuildContext ctx) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Maps Sample App'),
      backgroundColor: Colors.lightBlue,
    ),
    body: GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: 11.0,
      ),
    ),
  );
  });
}