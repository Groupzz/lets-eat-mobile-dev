import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_eat/Friends.dart';
import 'package:lets_eat/UserYelpPreferences.dart';
import 'package:lets_eat/search.dart';
import 'package:lets_eat/signUpPage.dart';
import 'userAuth.dart';
import 'YelpRepository.dart';
import 'main.dart';
import 'maps.dart';
import 'userAuth.dart';
import 'login_root.dart';
import 'accounts.dart';
import 'authentication.dart';
import 'About.dart';
import 'YelpSearch.dart';
import 'UserYelpPreferences.dart';
import 'LoginSignUp.dart';
import 'signUpPage.dart';

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
                  title: new Text('Choose My Preferences'),
                  onTap: () {
                    Route route = MaterialPageRoute(builder: (context) => UserYelpPreferences());
                    Navigator.push(context, route);
                  },
                ),
                new ListTile(
                  title: new Text('Sign In / Sign Up'),
                  onTap: () {
                    Route route = MaterialPageRoute(builder: (context) => SignupPage());
                   // Route route = MaterialPageRoute(builder: (context) => UserAuth());
                    //Route route = MaterialPageRoute(builder: (context) => LoginRootPage(auth: new Auth()));
                    Navigator.push(context, route);
                    //signIn(context);
//                    return UserAuth().createState().build(context);
                  },
                ),
                new ListTile(
                  title: new Text('Find me a restaurant'),
                  onTap: () {
                    //Repository repo = new Repository();
                    //Route route = MaterialPageRoute(builder: (context) => YelpSearch(repository: Repository()));
                    Route route = MaterialPageRoute(builder: (context) => tempSearch());
//                    Route route = MaterialPageRoute(builder: (context) => Repository());
                    Navigator.push(context, route);
                  },
                ),
                new ListTile(
                  title: new Text("My Friends"),
                  onTap: () {
                    Route route = MaterialPageRoute(builder: (context) => FriendsPage(auth: new Auth()));
                    Navigator.push(context, route);
                  }
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
              icon: const Icon(Icons.my_location),
              tooltip: 'Nearby Restaurants',
              onPressed: () {
                //openPage(context);
                Route route = MaterialPageRoute(builder: (context) => MapView());
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
                image: new DecorationImage(image: new AssetImage("assets/mobileHome.JPG"), fit: BoxFit.fill,),
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