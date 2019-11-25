import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_eat/FriendsPage.dart';
import 'package:lets_eat/GroupVotePage.dart';
import 'package:lets_eat/Accounts/UserYelpPreferences.dart';
import 'package:lets_eat/HomeSearch.dart';
import 'package:lets_eat/search.dart';
import 'package:lets_eat/Accounts/signUpPage.dart';
import 'Accounts/userAuth.dart';
import 'YelpRepository.dart';
import 'main.dart';
import 'maps.dart';
import 'Accounts/login_root.dart';
import 'Accounts/userAuth.dart';
import 'Accounts/accounts.dart';
import 'Accounts/login_root.dart';
import 'Accounts/accounts.dart';
import 'Accounts/authentication.dart';
import 'About.dart';
import 'YelpSearch.dart';
import 'Accounts/UserYelpPreferences.dart';
import 'Accounts/LoginSignUp.dart';
import 'Accounts/signUpPage.dart';
import 'SearchList.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final searchController = TextEditingController();
  final locController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    Widget _selectPopup() => PopupMenuButton<int>(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: TextFormField(
            controller: searchController,
            maxLines: 1,
            keyboardType: TextInputType.text,
            autofocus: false,
            decoration: new InputDecoration(
                hintText: 'Enter search term',
                icon: new Icon(
                  Icons.search,
                  color: Colors.grey,
                )),
            validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
            onSaved: (value) {

            },
          ),
        ),

        PopupMenuItem(
          value: 2,
          child: TextFormField(
            controller: locController,
            maxLines: 1,
            keyboardType: TextInputType.text,
            autofocus: false,
            decoration: new InputDecoration(
                hintText: 'Current Location',
                icon: new Icon(
                  Icons.location_on,
                  color: Colors.grey,
                )),
            validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
            onSaved: (value) {

            },
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.blue,
              child: new Text('Search',
                  style: new TextStyle(fontSize: 16.0, color: Colors.white)),
              onPressed: () {
                String query = "";
                if(searchController.text.isNotEmpty){
                  query = searchController.text;
                }
                if(locController.text.isNotEmpty){
                  query += "&location="+locController.text;
                }
                Route route = MaterialPageRoute(builder: (context) => HomeSearchPage(query: query,));
                Navigator.push(context, route);
              }
          ),
        ),
      ],
      onCanceled: () {
        print("You have canceled the menu.");
      },
      onSelected: (value) {
        if(value == 1){
        }
      },
      icon: Icon(Icons.search),
    );


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
                    Route route = MaterialPageRoute(builder: (context) => LoginRootPage(auth: new Auth()));
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
                    Route route = MaterialPageRoute(builder: (context) => searchPage());
//                    Route route = MaterialPageRoute(builder: (context) => Repository());
                    Navigator.push(context, route);
                  },
                ),
                new ListTile(
                  title: new Text('Group Voting'),
                  onTap: () {
                    //Repository repo = new Repository();
                    //Route route = MaterialPageRoute(builder: (context) => YelpSearch(repository: Repository()));
                    Route route = MaterialPageRoute(builder: (context) => GroupVotePage(auth: new Auth()));
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
            _selectPopup(),
//            IconButton(
//              icon: const Icon(Icons.search),
//              tooltip: 'Show Snackbar',
//              onPressed: () {
//                Route route = MaterialPageRoute(builder: (context) => SearchList());
//                Navigator.push(context, route);
//              },
//            ),
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