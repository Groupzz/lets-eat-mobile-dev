

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'YelpRepository.dart';

class UserInput {

}

var cuisineListEthnic = ["American","Mexican","Japanese","Korean","Chinese","Indian","Thai","Mediterranean","Italian","French"];
var pricepointList = [1,2,3,4];

List<String> userCuisinePref = [];

bool American = false;
bool Mexican = false;
bool Japanese = false;
bool Korean = false;
bool Chinese = false;
bool Indian = false;
bool Thai = false;
bool Mediterranean = false;
bool Italian = false;
bool French = false;

bool price1 = false;
bool price2 = false;
bool price3 = false;
bool price4 = false;

class UserYelpPreferences extends StatelessWidget{

  void updatePref(){
    print(userCuisinePref);
    //pass string list to yelp repo
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
            //onSelected: (List<String> selected) =>print(selected.toString()),
          ),
          Divider(
            thickness: 10.0,
          ),
          RaisedButton(
            onPressed: (){updatePref();},
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