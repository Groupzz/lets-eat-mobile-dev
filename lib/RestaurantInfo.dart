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
import 'RestaurantData.dart';
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
import 'package:carousel_slider/carousel_slider.dart';
import 'Accounts/authentication.dart';


class RestaurantInfoPage extends StatefulWidget {
  RestaurantInfoPage({this.query, this.name});

  final String query;
  final String name;

  @override
  State<StatefulWidget> createState() => new _RestaurantInfoPageState();

  static Future<void> saveRestaurantDB(BuildContext c, snap,String rID,String rName) async{

    Firestore.instance
        .collection('likedRestaurants')
        .where(
        'id', isEqualTo: uid)
        .snapshots()
        .listen(
            (data) {
          Firestore.instance
              .collection('likedRestaurants')
              .document(data.documents[0].documentID)
              .updateData(
              {'restaurantIDs':FieldValue.arrayUnion([rID])}
          );
        }
    );
    showDialog(
      context: c,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Restaurant Saved!"),
          content: new Text("${rName} has been added to your saved Restaurants"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void saveRestaurant(BuildContext context, String restaurantID,String restaurantName) async{
    bool success = true;
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();//auth.currentUser();

    if(user == null){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("You Must Sign In First"),
            content: new Text(
                "You must be signed in to save restaurants"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Sign In "),
                onPressed: () {
                  Route route = MaterialPageRoute(builder: (context) =>
                      LoginRootPage(auth: new Auth(),));
                  Navigator.push(context, route);
                },
              ),
              new FlatButton(
                child: new Text("Dismiss"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    else {
      try {
        uid = user.uid;
        // Check if provided restaurant is already saved in database
        Firestore.instance
            .collection('likedRestaurants')
            .where(
            'restaurantIDs', isEqualTo: restaurantID)
            .snapshots()
            .listen(

                (data) =>
            data.documents.length == 0
            // If so, update user's restaurant array w/ new restaurant
                ? Firestore.instance
                .collection('users')
                .where(
                'id', isEqualTo: uid // Get current user id
            )
                .snapshots()
                .listen(
              // Update Restaurants collection that contains current user ID
                    (data) =>
                    saveRestaurantDB(context, data, restaurantID, restaurantName)
            )
            // If not, show error message
                : showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text("Restaurant is already saved"),
                  //content: new Text("We didn't find a user with that username.  Please make sure the username is correct"),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Dismiss"),
                      onPressed: () {
                        success = false;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            )
        );
      }
      catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Something Went Wrong!"),
              content: new Text(
                  "We were unable to save this restaurant to your account.\n"
                      "Please make sure you are connected to the internet and try again"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Sign In "),
                  onPressed: () {
                    Route route = MaterialPageRoute(builder: (context) =>
                        LoginRootPage(auth: new Auth(),));
                    Navigator.push(context, route);
                  },
                ),
                new FlatButton(
                  child: new Text("Dismiss"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}


class _RestaurantInfoPageState extends State<RestaurantInfoPage>{

  static const String API_KEY = "p8eXXM3q_ks6WY_FWc2KhV-EmLhSpbJf0P-SATBhAIM4dNCgsp3sH8ogzJPezOT6LzFQlb_vcFfxziHbHuNt8RwxtWY0-vRpx7C0nPz5apIT4A5LYGmaVfuwPrf3WXYx";
  static const Map<String, String> AUTH_HEADER = {"Authorization": "Bearer $API_KEY"};

  var ratingsTable = {0:"assets/stars_small_0.png", 1:"assets/stars_small_1.png", 1.5:"assets/stars_small_1_half.png", 2:"assets/stars_small_2.png", 2.5:"assets/stars_small_2_half.png", 3:"assets/stars_small_3.png",
    3.5:"assets/stars_small_3_half.png", 4:"assets/stars_small_4.png", 4.5:"assets/stars_small_4_half.png", 5:"assets/stars_small_5.png"};

  Map<String, List<int>> restaurantHours;// = {"Monday": [0,0], "Tuesday":[0,0], "Wednesday":[0,0], "Thursday":[0,0], "Friday":[0,0], "Saturday":[0,0], "Sunday":[0,0]};
  String result;

  var dayOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    restaurantHours = {"Monday": null, "Tuesday":null, "Wednesday":null, "Thursday":null, "Friday":null, "Saturday":null, "Sunday":null};
    result = "hello";
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
    });
  }

  _launchURL(String url) async {
    String url1 = url;
    if (await canLaunch(url1)) {
      await launch(url1);
    } else {
      throw 'Could not launch $url1';
    }
  }

  void parseHours(List<dynamic> hours){
    int start, end;
    bool mondaySplit = false;
    bool tuesdaySplit = false;
    bool wednesdaySplit = false;
    bool thursdaySplit = false;
    bool fridaySplit = false;
    bool saturdaySplit = false;
    bool sundaySplit = false;
    result = "                  Hours:";
    for(var day in hours){
      print("DAY: " + day['day'].toString());
      start = int.parse(day['start']);
      end = int.parse(day['end']);
      if(start > 1259)
        start -= 1200;
      if(end > 1255)
        end -= 1200;

      if(start < 0060){
        start += 1200;
      }
      if(end < 0060){
        end += 1200;
      }

      if(day['day'] == 0){
        restaurantHours['Monday'] = [start, end];
        if(mondaySplit){
          result += ";   $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
        }
        else if(day['is_overnight']){
          result += "\nMonday:         All Day";
        }
        else if(restaurantHours['Monday'] != null){
          result += "\nMonday:         $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
          mondaySplit = true;
        }
        else{
          result += "\nMonday:         Closed";
        }
      }

      if(day['day'] == 1){
        restaurantHours['Tuesday'] = [start, end];
        if(tuesdaySplit){
          result += ";   $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
        }
        else if(day['is_overnight']){
          result += "\nTuesday:        All Day";
        }
        else if(restaurantHours['Tuesday'] != null){
          result += "\nTuesday:        $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
          tuesdaySplit = true;
        }
        else{
          result += "\nTuesday:        Closed";
        }
      }

      else if(day['day'] == 2){
        restaurantHours['Wednesday'] = [start, end];
        if(wednesdaySplit){
          result += ";   $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
        }
        else if(day['is_overnight']){
          result += "\nWednesday:  All Day";
        }
        else if(restaurantHours['Wednesday'] != null){
          result += "\nWednesday:  $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
          wednesdaySplit = true;
        }
        else{
          result += "\nWednesday:  Closed";
        }
      }
      else if(day['day'] == 3){
        restaurantHours['Thursday'] = [start, end];
        if(thursdaySplit){
          result += ";   $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
        }
        else if(day['is_overnight']){
          result += "\nThursday:      All Day";
        }
        else if(restaurantHours['Thursday'] != null){
          result += "\nThursday:      $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
          thursdaySplit = true;
        }
        else{
          result += "\nThursday:      Closed";
        }
      }
      else if(day['day'] == 4){
        restaurantHours['Friday'] = [start, end];
        if(fridaySplit){
          result += ";   $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
        }
        else if(day['is_overnight']){
          result += "\nFriday:            All Day";
        }
        else if(restaurantHours['Friday'] != null){
          result += "\nFriday:            $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
          fridaySplit = true;
        }
        else{
          result += "\nFriday:            Closed";
        }
      }
      else if(day['day'] == 5){
        restaurantHours['Saturday'] = [start, end];
        if(saturdaySplit){
          result += ";   $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
        }
        if(day['is_overnight']){
          result += "\nSaturday:       All Day";
        }
        else if(restaurantHours['Saturday'] != null){
          result += "\nSaturday:       $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
          saturdaySplit = true;
        }
        else{
          result += "\nSaturday:       Closed";
        }
      }
      else if(day['day'] == 6){
        restaurantHours['Sunday'] = [start, end];
        if(sundaySplit){
          result += ";   $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
        }
        if(day['is_overnight']){
          result += "\nSunday:          All Day";
        }
        else if(restaurantHours['Sunday'] != null){
          result += "\nSunday:          $start - $end";
          if(int.parse(day['end']) > 1259){
            result += " PM";
          }
          else{
            result += " AM";
          }
          sundaySplit = true;
        }
        else{
          result += "\nSunday:          Closed";
        }
      }
      print("RESULT == " + result);
    }
  }

  Future<Map<String, dynamic>> lookupRestaurant(var id) async {
    String webAddress;

    webAddress = "https://api.yelp.com/v3/businesses/" + id; //-118.112858";

    print("API REQUEST = " + webAddress);
    //webAddress = "https://api.yelp.com/v3/businesses/search?latitude=33.783022&longitude=-118.112858";
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

    print("LOCATION = " + map['location']['address1'].toString());

    print("RESPONSE = " + map.toString());
    return map;

  }

//  static void saveRestaurant(String restaurantID,String restaurantName) async{
//    bool success = true;
//    final FirebaseUser user = await FirebaseAuth.instance.currentUser();//auth.currentUser();
//
//    if(user == null){
//      showDialog(
//        //context: context,
//        builder: (BuildContext context) {
//          // return object of type Dialog
//          return AlertDialog(
//            title: new Text("You Must Sign In First"),
//            content: new Text(
//                "You must be signed in to save restaurants"),
//            actions: <Widget>[
//              new FlatButton(
//                child: new Text("Sign In "),
//                onPressed: () {
//                  Route route = MaterialPageRoute(builder: (context) =>
//                      LoginRootPage(auth: new Auth(),));
//                  Navigator.push(context, route);
//                },
//              ),
//              new FlatButton(
//                child: new Text("Dismiss"),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                },
//              ),
//            ],
//          );
//        },
//      );
//    }
//    else {
//      try {
//        uid = user.uid;
//        // Check if provided restaurant is already saved in database
//        Firestore.instance
//            .collection('likedRestaurants')
//            .where(
//            'restaurantIDs', isEqualTo: restaurantID)
//            .snapshots()
//            .listen(
//
//                (data) =>
//            data.documents.length == 0
//            // If so, update user's restaurant array w/ new restaurant
//                ? Firestore.instance
//                .collection('users')
//                .where(
//                'id', isEqualTo: uid // Get current user id
//            )
//                .snapshots()
//                .listen(
//              // Update Restaurants collection that contains current user ID
//                    (data) =>
//                    saveRestaurantDB(data, restaurantID, restaurantName)
//            )
//            // If not, show error message
//                : showDialog(
//              context: context,
//              builder: (BuildContext context) {
//                // return object of type Dialog
//                return AlertDialog(
//                  title: new Text("Restaurant is already saved"),
//                  //content: new Text("We didn't find a user with that username.  Please make sure the username is correct"),
//                  actions: <Widget>[
//                    new FlatButton(
//                      child: new Text("Dismiss"),
//                      onPressed: () {
//                        success = false;
//                        Navigator.of(context).pop();
//                      },
//                    ),
//                  ],
//                );
//              },
//            )
//        );
//      }
//      catch (e) {
//        showDialog(
//          //context: context,
//          builder: (BuildContext context) {
//            // return object of type Dialog
//            return AlertDialog(
//              title: new Text("Something Went Wrong!"),
//              content: new Text(
//                  "We were unable to save this restaurant to your account.\n"
//                      "Please make sure you are connected to the internet and try again"),
//              actions: <Widget>[
//                new FlatButton(
//                  child: new Text("Sign In "),
//                  onPressed: () {
//                    Route route = MaterialPageRoute(builder: (context) =>
//                        LoginRootPage(auth: new Auth(),));
//                    Navigator.push(context, route);
//                  },
//                ),
//                new FlatButton(
//                  child: new Text("Dismiss"),
//                  onPressed: () {
//                    Navigator.of(context).pop();
//                    Navigator.of(context).pop();
//                  },
//                ),
//              ],
//            );
//          },
//        );
//      }
//    }
//  }

//  Future<void> saveRestaurantDB(QuerySnapshot snap,String rID,String rName) async{
//
//    Firestore.instance
//        .collection('likedRestaurants')
//        .where(
//        'id', isEqualTo: uid)
//        .snapshots()
//        .listen(
//            (data) {
//          Firestore.instance
//              .collection('likedRestaurants')
//              .document(data.documents[0].documentID)
//              .updateData(
//              {'restaurantIDs':FieldValue.arrayUnion([rID])}
//          );
//        }
//    );
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: new Text("Restaurant Saved!"),
//          content: new Text("${rName} has been added to your saved Restaurants"),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text("Dismiss"),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//      title: "Selected Restaurant",
//      home: Scaffold(
      appBar: AppBar(
          title: Text(widget.name),

      ),
      body: Center(
//          child: FutureBuilder<List<Restaurants>>(
        child: FutureBuilder<Map<String,dynamic>>(
          future: lookupRestaurant(widget.query),//repository.getBusinesses(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
//                print("Selected Restaurant = " + snapshot.data.name);
//                print("It is located in " + snapshot.data.city + " at " + snapshot.data?.address1??"" + " " + snapshot.data?.address2??"" + " " + snapshot.data?.address3??"");


             // chosenRestaurant = snapshot.data;

              Iterable markers = [];  // Holds list of Restaurant markers (Will hold only 1 marker in this case)
              Iterable _markers = Iterable.generate(1, (index) {
                LatLng markerLoc = LatLng(snapshot.data['coordinates']['latitude'], snapshot.data['coordinates']['longitude']);
                return Marker(markerId: MarkerId("marker$index"), position: markerLoc,infoWindow: InfoWindow(
                  title: snapshot.data['name'],
                ));
              });

              markers = _markers;

//              print("TRANSACTIONS = " + snapshot.data['transactions'].toString());
              List<dynamic> openStatus = snapshot.data['hours'];
              List<dynamic> openHours = openStatus[0]['open'];
              List<Image> photos = [];
              parseHours(openHours);
              for(int i = 0; i < snapshot.data['photos'].length; i++){
                photos.add(Image.network(snapshot.data['photos'][i]??"", width: 300, height: 300,));
              }
//              print("OPENSTATUS = " + openStatus[0]['is_open_now'].toString());

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
                                    leading: Image.network(snapshot.data['image_url']??"", width: 90, height: 90,),
                                    title: Text('${snapshot.data['name']}'),
                                    subtitle: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.body1,
                                          children: [
                                            TextSpan(text: '${snapshot.data['location']['address1']} ${snapshot.data['location']['address2']} ${snapshot.data['location']['city']}'
                                                '\n${snapshot.data['price']}    '),
                                            TextSpan(text: '${openStatus[0]['is_open_now']?'Open   ':'Closed   '}', style: openStatus[0]['is_open_now']?TextStyle(color: Colors.green):TextStyle(color: Colors.red)),
                                            TextSpan(text: ' ${snapshot.data['display_phone']}\n'),
                                            WidgetSpan(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                  child: Image(
                                                    image: AssetImage(ratingsTable[snapshot.data['rating']]),
                                                    fit: BoxFit.fill,
                                                  ),
                                                )),
                                            TextSpan(text: ' ${snapshot.data['review_count']}', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),

                                          ],
                                        ))),
//                                  ListTile(
//                                    title: Text('${snapshot.data.price}')
//                                  ),

                                // make buttons use the appropriate styles for cards
                                ButtonTheme.bar(
                                  child: ButtonBar(
                                    children: <Widget>[
                                      IconButton(
                                          icon: const Icon(Icons.call),
                                          color: Colors.green,
                                          tooltip: 'Restaurant Info',
                                          onPressed: () {
                                            launch("tel:" + snapshot.data['phone']);
                                          }
                                      ),
                                      FlatButton(
                                        child: const Text('Save'),
                                        onPressed: () {
                                          RestaurantInfoPage.saveRestaurant(context, snapshot.data['id'],snapshot.data['name']);
                                          //_launchURL(snapshot.data[index].url);
                                        },
                                      ),

                                      FlatButton(
                                        child: const Text('Directions'),
                                        onPressed: () {
                                          //_launchURL(snapshot.data.)
                                          _launchURL("google.navigation:q=${snapshot.data['coordinates']['latitude']},${snapshot.data['coordinates']['longitude']}");
                                        },
                                      ),
                                      SizedBox(
                                        width: 80.0,
                                        height: 80.0,
                                        child: FlatButton(
                                          child: Image(
                                            image: AssetImage('assets/yelpBig.png'),
                                            fit: BoxFit.contain,
                                          ),
                                          onPressed: () {
                                            _launchURL(snapshot.data['url']);
                                            //_launchURL(snapshot.data[index].url);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

//                                ButtonTheme.bar(
//                                  child: ButtonBar(
//                                    children: <Widget>[
//                                      FlatButton(
//                                        child: Image.network(snapshot.data['photos'][0]??"", width: 100, height: 100,),
//                                        onPressed: () {
//                                          saveRestaurant(snapshot.data['id'],snapshot.data['name']);
//                                          //_launchURL(snapshot.data[index].url);
//                                        },
//                                      ),
//
//                                      FlatButton(
//                                        child: Image.network(snapshot.data['photos'][1]??"", width: 100, height:100,),
//                                        onPressed: () {
//                                          //_launchURL(snapshot.data.)
//                                          _launchURL("google.navigation:q=${snapshot.data['coordinates']['latitude']},${snapshot.data['coordinates']['longitude']}");
//                                        },
//                                      ),
//                                      FlatButton(
//                                          child: Image.network(snapshot.data['photos'][2]??"", width: 100, height: 100,),
//                                          onPressed: () {
//                                            _launchURL(snapshot.data['url']);
//                                            //_launchURL(snapshot.data[index].url);
//                                          },
//                                      ),
//                                    ],
//                                  ),
//                                ),
//                              Text("Photos"),
//                                Image.network(snapshot.data['photos'][0]??"", width: 300, height: 300,),
//                                Image.network(snapshot.data['photos'][1]??"", width: 300, height: 300,),
//                                Image.network(snapshot.data['photos'][2]??"", width: 300, height: 300,),

                                Container(
                                    width: 300.0,
                                    height: 130.0,
                                    child: Text(result)
//                                    child: Text("Monday: ${restaurantHours['Monday'][0] == 0?("Closed"): (restaurantHours['Monday'][0] - restaurantHours['Monday'][1])}"
//                                        "\nTuesday: ${restaurantHours['Tuesday'][0] == 0?("Closed"): (restaurantHours['Tuesday'][0] - restaurantHours['Tuesday'][1])}"
//                                        "\nWednesday: ${restaurantHours['Wednesday'][0] == 0?("Closed"): (restaurantHours['Wednesday'][0] - restaurantHours['Wednesday'][1])}"
//                                        "\nThursday: ${restaurantHours['Thursday'][0] == 0?("Closed"): (restaurantHours['Thursday'][0] - restaurantHours['Thursday'][1])}"
//                                        "\nTuesday: ${restaurantHours['Friday'][0] == 0?("Closed"): (restaurantHours['Friday'][0] - restaurantHours['Friday'][1])}")

                                ),
//                                Padding(
//                                  padding: const EdgeInsets.all(8.0),
//                                  child: Text("Monday: ${restaurantHours == null?"Closed":restaurantHours['Monday'][0]} - ${restaurantHours['Monday'][1]}")
//                                ),

                                CarouselSlider(
                                  items: photos,
                                  height: 300,
                                  aspectRatio: 16/9,
                                  viewportFraction: 0.8,
                                  initialPage: 0,
                                  enableInfiniteScroll: true,
                                  reverse: false,
                                  autoPlay: true,
                                  autoPlayInterval: Duration(seconds: 3),
                                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  pauseAutoPlayOnTouch: Duration(seconds: 3),
                                  enlargeCenterPage: true,
                                  scrollDirection: Axis.horizontal,
                                ),

                                Container(
                                    width: 350.0,
                                    height: 350.0,
                                    child: GoogleMap(
                                      onMapCreated: _onMapCreated,
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
                                        target: LatLng(snapshot.data['coordinates']['latitude'], snapshot.data['coordinates']['longitude']),
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
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: Text("Something went wrong.\nPlease try again or modify your search"));
            }

            // By default, show a loading spinner
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}