import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'maps.dart';
import 'Restaurants.dart';
import 'server.dart';
import 'userAuth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Let\'s Eat';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
        home: Home(),
//      home: new StreamBuilder(
//        stream: auth.onAuthStateChanged,
//        builder: (context, snapshot) {
//          if (snapshot.hasData) {
//            return Home();
//          }
//          return Home();
//        },
//      ),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new Home(),
        '/login': (BuildContext context) => new UserAuth()
      },
    );
  }
}

final FirebaseAuth auth = FirebaseAuth.instance;

class YelpSearch extends StatelessWidget {
  final Repository repository;

  YelpSearch({Key key, this.repository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Yelp Test",
      home: Scaffold(
        appBar: AppBar(title: Text("Yelp Test")),
        body: Center(
          child: FutureBuilder<List<Restaurants>>(
            future: repository.getBusinesses(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: Card(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(padding: const EdgeInsets.all(8.0)),
                                  ListTile(
                                    leading: Image.network(snapshot.data[index].imageUrl, width: 80, height: 80,),
                                    title: Text('${snapshot.data[index].name}'),
                                    subtitle: Text('${snapshot.data[index].distance.toStringAsFixed(2)} distance'),
                                  ),
                                  ButtonTheme.bar(
                                    // make buttons use the appropriate styles for cards
                                    child: ButtonBar(
                                      children: <Widget>[
                                        FlatButton(
                                          child: const Text('WEBSITE'),
                                          onPressed: () {
                                            _launchURL(snapshot.data[index].url);
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


final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
final SnackBar snackBar = const SnackBar(content: Text('Showing Snackbar'));

void search(BuildContext context)
{
  Repository repository;
  Navigator.push(context, MaterialPageRoute(
    builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("Yelp Search")),
        body: Center(
          child: FutureBuilder<List<Restaurants>>(
            future: repository.getBusinesses(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: Card(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(padding: const EdgeInsets.all(8.0)),
                                  ListTile(
                                    leading: Image.network(snapshot.data[index].imageUrl, width: 80, height: 80,),
                                    title: Text('${snapshot.data[index].name}'),
                                    subtitle: Text('${snapshot.data[index].distance.toStringAsFixed(2)} distance'),
                                  ),
                                  ButtonTheme.bar(
                                    // make buttons use the appropriate styles for cards
                                    child: ButtonBar(
                                      children: <Widget>[
                                        FlatButton(
                                          child: const Text('WEBSITE'),
                                          onPressed: () {
                                            _launchURL(snapshot.data[index].url);
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
      );
      })
  );
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void signIn(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(
    builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 32.0,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Builder(
                    builder: (context) {
                      return RaisedButton(
                        onPressed: () => print('PRESSED'),
                        color: Colors.lightBlue,
                        child: Text('Sign In'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Builder(
                    builder: (context) {
                      return RaisedButton(
                        onPressed: () => print('PRESSED'),
                        color: Colors.lightBlue[200],
                        child: Text('Sign Up'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ));
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: new Drawer(
          child: new ListView(
            children: <Widget> [
              new DrawerHeader(child: new Text('Menu'),),
              new ListTile(
                title: new Text('Sign In / Sign Up'),
                onTap: () {
                  signIn(context);
                },
              ),
              new ListTile(
                title: new Text('Find me a restaurant'),
                onTap: () {
                  runApp(YelpSearch(repository : Repository.get()));
                },
              ),
              new Divider(),
              new ListTile(
                title: new Text('About'),
                onTap: () {},
              ),
            ],
          )
      ),
      appBar: AppBar(

        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
                },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: const Text('Let\'s Eat - Home'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Show Snackbar',
            onPressed: () {
              scaffoldKey.currentState.showSnackBar(snackBar);
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Next page',
            onPressed: () {
              //openPage(context);
              Navigator.push(context, Maps());
              //runApp(Server());
            },
          ),
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Text('Welcome to Let\'s Eat!',
            style: TextStyle(fontSize: 24)),
          ),
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(image: new AssetImage("assets/logo.gif"), fit: BoxFit.contain,),
            ),
          ),
//          new Center(
//            child: new Text('Welcome to Let\'s Eat!',
//          style: TextStyle(fontSize: 24),),
//          )
        ],
      )
//      body: const Center(
//        child: Text(
//          'Welcome to Let\'s Eat!',
//          style: TextStyle(fontSize: 24),
//        ),
//      ),
    );

  }
}
