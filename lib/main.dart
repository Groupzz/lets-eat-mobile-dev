import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'maps.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Let\'s Eat';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatelessWidget(),
    );
  }
}

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
final SnackBar snackBar = const SnackBar(content: Text('Showing Snackbar'));

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
                onTap: () {},
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
