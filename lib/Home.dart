import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'userAuth.dart';
import 'server.dart';
import 'main.dart';
import 'maps.dart';
import 'userAuth.dart';
import 'login_root.dart';
import 'accounts.dart';
import 'authentication.dart';
import 'About.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

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
                    Route route = MaterialPageRoute(builder: (context) => LoginRootPage(auth: new Auth()));
//                    Route route = MaterialPageRoute(builder: (context) => UserAuth());
                    Navigator.push(context, route);
                    //signIn(context);
//                    return UserAuth().createState().build(context);
                  },
                ),
                new ListTile(
                  title: new Text('Find me a restaurant'),
                  onTap: () {
                    Route route = MaterialPageRoute(builder: (context) => YelpSearch(repository : Repository.get()));
                    Navigator.push(context, route);
                  },
                ),
                new Divider(),
                new ListTile(
                  title: new Text('About'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => About())
                    );
                  },
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
                Route route = MaterialPageRoute(builder: (context) => Map());
                Navigator.push(context, route);
//                Navigator.push(context, Maps());
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