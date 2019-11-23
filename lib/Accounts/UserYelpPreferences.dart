

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authentication.dart';
import '../YelpRepository.dart';

var cuisineListEthnic = ["American","Mexican","Japanese","Korean","Chinese","Indian","Thai","Mediterranean","Italian","French"];
var dietaryRestrictions = ["Vegetarian","Vegan","Halal","Pescetarian"];
var pricepointList = [1,2,3,4];

List<String> userCuisinePref = [];
List<String> userDietPref = [];
List<String> userPricePref = [];

String cuisineURL;
String dietURL;
String priceURL;

class UserYelpPreferences extends StatelessWidget{

  void getCurrentPrefandUpdate(BuildContext context) async{
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final String uid = user.uid;

    cuisineURL = parseCuisine();
    dietURL = parseDiet();
    priceURL = parsePrice();

    try {
      Firestore.instance
          .collection('preferences')
          .where('userID', isEqualTo: uid)
          .snapshots()
          .listen((data) => updatePref(data));


    }catch(e){
      print("Could not find user");
      Firestore.instance
          .collection('preferences')
          .add({
            'userID':uid,
          });
    }
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: new Text("Preferences Updated"),
            content: new Text("Your custom preferences have been updated"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Dismiss"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }
  
  Future<void> updatePref(QuerySnapshot snap)async{
    Firestore.instance
        .collection('preferences')
        .document(snap.documents[0].documentID)
        .updateData({
          'cuisineURL':cuisineURL,
          'dietURL':dietURL,
          'priceURL':priceURL
          });
  }
  
  String parsePrice(){ //Converts dollar signs to string ints and return URL ready string
    List<String> userPricePrefTemp = new List(userPricePref.length);
    if(userPricePref.isNotEmpty == true) {
      for (var i = 0; i < userPricePref.length; i++) {
        switch(userPricePref[i].length){
          case 1: {
            userPricePrefTemp[i] = "1";
          }
          break;
          case 2: {
            userPricePrefTemp[i] = "2";
          }
          break;
          case 3: {
            userPricePrefTemp[i] = "3";
          }
          break;
          case 4: {
            userPricePrefTemp[i] = "4";
          }
          break;
        }
      }
    }
    userPricePref = userPricePrefTemp;
    String temp = "";
    for(int i = 0; i<userPricePref.length;i++){
      if(i==0){
        temp = temp+userPricePref[i];
      }
      if(i!=0){
        temp = temp + "+" + userPricePref[i];
      }
    }
    return temp;
  }

  //Converts cuisine list into URL ready string
  String parseCuisine(){
    String temp = "";
    for(int i = 0; i<userCuisinePref.length;i++){
      if(i==0){
        temp = temp+userCuisinePref[i];
      }
      if(i!=0){
        temp = temp + "+" + userCuisinePref[i];
      }
    }
    return temp;
  }
  //Converts diet list into URL ready string
  String parseDiet(){
    String temp = "";
    for(int i = 0; i<userDietPref.length;i++){
      if(i==0){
        temp = temp+userDietPref[i];
      }
      if(i!=0){
        temp = temp + "+" + userDietPref[i];
      }
    }
    return temp;
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(

        appBar: AppBar(
          title: Text("Choose My Preferences"),
        ),
        body: SingleChildScrollView(
            child:Column(
                children: <Widget>[
                  Divider(
                    thickness: 10.0,
                  ),
                  Text(
                    'Cuisine Preferences',
                    textScaleFactor: 2.0,
                    textAlign: TextAlign.center,

                  ),
                  Divider(
                    thickness: 10.0,
                  ),
                  CheckboxGroup(
                    labels: cuisineListEthnic,
                    onSelected: (List<String> selected) => userCuisinePref = selected,
                  ),


                  Divider(
                    thickness: 10.0,
                  ),
                  Text(
                    'Price Preferences',
                    textScaleFactor: 2.0,
                    textAlign: TextAlign.left,

                  ),
                  Divider(
                    thickness: 10.0,
                  ),
                  CheckboxGroup(
                    labels: <String>[
                      "\$","\$\$","\$\$\$","\$\$\$\$"
                    ],
                    onSelected: (List<String> selected) => userPricePref = selected,
                  ),
                  Divider(
                    thickness: 10.0,
                  ),

                  Text(
                    'Dietary Restrictions',
                    textScaleFactor: 2.0,
                    textAlign: TextAlign.left,

                  ),
                  Divider(
                    thickness: 10.0,
                  ),
                  CheckboxGroup(
                    labels: dietaryRestrictions,
                    onSelected: (List<String> selected) => userDietPref = selected,
                  ),
                  Divider(
                    thickness: 10.0,
                  ),
                  RaisedButton(
                    onPressed: (){getCurrentPrefandUpdate(context);},
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Color(0xFF0D47A1),
                                Color(0xFF1976D2),
                                Color(0xFF42A5F5),
                              ],
                            )
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: const Text(
                          'Update My Preferences',
                          style: TextStyle(fontSize: 20),
                        )
                    ),
                  ),
                  Divider(
                    thickness: 10.0,
                  ),
                ]
            )
        )
    );
  }
}