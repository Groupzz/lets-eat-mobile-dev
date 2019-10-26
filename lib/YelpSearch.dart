import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_eat/About.dart';
import 'package:location/location.dart';
import 'maps.dart';
import 'Restaurants.dart';
import 'YelpRepository.dart';
import 'userAuth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'About.dart';
import 'main.dart';

class YelpSearch extends StatelessWidget {
  final Repository repository;

  YelpSearch({Key key, this.repository}) : super(key: key);

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
        body: Center(
//          child: FutureBuilder<List<Restaurants>>(
          child: FutureBuilder<Restaurants>(
            future: Repository().createState().findRandomRestaurant(),//repository.getBusinesses(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print("Selected Restaurant = " + snapshot.data.name);
                print("It is located in " + snapshot.data.city + " at " + snapshot.data?.address1??"" + " " + snapshot.data?.address2??"" + " " + snapshot.data?.address3??"");
                double miles = snapshot.data.distance * 0.000621371;

                Iterable markers = [];
                Iterable _markers = Iterable.generate(1, (index) {
                  LatLng markerLoc = LatLng(snapshot.data.latitude, snapshot.data.longitude);
                  return Marker(
                    markerId: MarkerId("marker$index"),
                    position: markerLoc,
                    infoWindow: InfoWindow(
                      title: snapshot.data.name,
                    ),
                  );
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
                                    zoomGesturesEnabled: true,
                                    minMaxZoomPreference: MinMaxZoomPreference.unbounded,
                                    mapType: MapType.normal,
                                    myLocationButtonEnabled: true,
                                    myLocationEnabled: true,
                                    initialCameraPosition: CameraPosition(
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