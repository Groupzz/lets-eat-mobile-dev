import 'package:flutter/material.dart';
import 'YelpSearch.dart';
import 'YelpRepository.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class tempSearch extends StatefulWidget
{
  @override
  tempSearchState createState() {
    return tempSearchState();
  }
}

class tempSearchState extends State<tempSearch> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  String _query;
  bool _isIos;
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

  void updatePref(){
    print(userCuisinePref);
    //pass string list to yelp repo
  }

  Widget _showSearchInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: new TextFormField(
        controller: controller,
        maxLines: 1,
        obscureText: false,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'What Are You In The Mood For?',
            icon: new Icon(
              Icons.restaurant,
              color: Colors.grey,
            )),
        //validator: (value) => value.isEmpty ? value = "" : value = value,
        onSaved: (value) => _query = value.trim(),
      ),
    );
  }

//  Padding(
//  padding: const EdgeInsets.symmetric(vertical: 16.0),
//  child: RaisedButton(
//  onPressed: () {
//  // Validate returns true if the form is valid, or false
//  // otherwise.
//  if (_formKey.currentState.validate()) {
//  // If the form is valid, display a Snackbar.
//  Route route = MaterialPageRoute(builder: (context) => YelpSearch(_query));
////                    Route route = MaterialPageRoute(builder: (context) => Repository());
//  Navigator.push(context, route);
//  }
//  },
//  child: Text('Submit'),
//  ),
//  ),

  @override
  Widget build(BuildContext context) {
      _isIos = Theme
          .of(context)
          .platform == TargetPlatform.iOS;
      return new Scaffold(
          appBar: new AppBar(
            title: new Text('Find a Restaurant'),
          ),
          body: Stack(
            children: <Widget>[
              _showSearchInput(),
//              Divider(
//                thickness: 100.0,
//              ),

//              Text(
//                'Cuisine Preferences',
//                textScaleFactor: 2.0,
//                textAlign: TextAlign.center,
//
//              ),
//              Divider(
//                thickness: 10.0,
//              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
                child: CheckboxGroup(
                  labels: cuisineListEthnic,
                  onSelected: (List<String> selected) => userCuisinePref = selected,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(270.0, 240.0, 0.0, 0.0),
                child: Text(
                  'Price Preferences',
                  textScaleFactor: 1.6,
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(250.0, 300.0, 0.0, 0.0),
                child: CheckboxGroup(
                  labels: <String>[
                    "\$","\$\$","\$\$\$","\$\$\$\$"
                  ],
                  //onSelected: (List<String> selected) =>print(selected.toString()),
                ),
              ),

//              CheckboxGroup(
//                labels: cuisineListEthnic,
//                onSelected: (List<String> selected) => userCuisinePref = selected,
//              ),
//
//
//              Divider(
//                thickness: 10.0,
//              ),
//              Text(
//                'Price Preferences',
//                textScaleFactor: 2.0,
//                textAlign: TextAlign.left,
//
//              ),
//              Divider(
//                thickness: 10.0,
//              ),
//              CheckboxGroup(
//                labels: <String>[
//                  "\$","\$\$","\$\$\$","\$\$\$\$"
//                ],
//                //onSelected: (List<String> selected) =>print(selected.toString()),
//              ),
//              Divider(
//                thickness: 10.0,
//              ),
//              RaisedButton(
//                onPressed: (){updatePref();},
//                textColor: Colors.white,
//                padding: const EdgeInsets.all(0.0),
//                child: Container(
//                    decoration: const BoxDecoration(
//                        gradient: LinearGradient(
//                          colors: <Color>[
//                            Color(0xFF0D47A1),
//                            Color(0xFF1976D2),
//                            Color(0xFF42A5F5),
//                          ],
//                        )
//                    ),
//                    padding: const EdgeInsets.all(10.0),
//                    child: const Text(
//                      'Update My Preferences',
//                      style: TextStyle(fontSize: 20),
//                    )
//                ),
//              ),
//              Divider(
//                thickness: 10.0,
//              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(300.0, 100.0, 0.0, 0.0),
                child: RaisedButton(
                  onPressed: () {
                    //print("puery = " + _query);
                    // Validate returns true if the form is valid, or false
                    // otherwise.

                      // If the form is valid, display a Snackbar.
                    Route route = MaterialPageRoute(builder: (context) => YelpSearch(controller.text));
//                    Route route = MaterialPageRoute(builder: (context) => Repository());
                    Navigator.push(context, route);

                  },
                  child: Icon(Icons.search),
                ),
              ),
            ],
          ));
    }
}