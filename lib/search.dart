import 'package:flutter/material.dart';
import 'YelpSearch.dart';
import 'YelpRepository.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class searchPage extends StatefulWidget
{
  @override
  searchPageState createState() {
    return searchPageState();
  }
}

class searchPageState extends State<searchPage> {
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
  var dietaryRestrictions = ["Vegetarian","Vegan","Halal","Pescetarian"];
  var pricepointList = [1,2,3,4];

  List<String> userCuisinePref = [];
  List<String> userPricePref = [];
  List<String> userDietPref = [];
  String cuisineURL="";
  String priceURL="";

  void updatePref(){
    String webAddress;
    cuisineURL = parseCuisine();
    priceURL = parsePrice();
    //print("price = " + priceURL);
//    String query = controller.text + "+" + cuisineURL;
    if(controller.text.isEmpty)
      {
        String query = "";
        if(cuisineURL.isNotEmpty){
          query = cuisineURL;
        }

        if(priceURL.isNotEmpty)
          {
            query += "&price=" + priceURL;
          }
        //query += "+price"
        print("query = " + query);
        Route route = MaterialPageRoute(builder: (context) => YelpSearch(query));
//                    Route route = MaterialPageRoute(builder: (context) => Repository());
        Navigator.push(context, route);
      }
    else
      {
        String query = controller.text;
        if(cuisineURL.isNotEmpty){
          query += "+" + cuisineURL;
        }
        //+ "+" + cuisineURL;
        if(priceURL.isNotEmpty)
        {
          query += "&price=" + priceURL;
        }
        print("query = " + query);
        Route route = MaterialPageRoute(builder: (context) => YelpSearch(query));
//                    Route route = MaterialPageRoute(builder: (context) => Repository());
        Navigator.push(context, route);
      }

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

  String parsePrice(){ //Converts dollar signs to string ints and return URL ready string
    //List<String> userPricePrefTemp = new List(userPricePref.length);
    if(userPricePref.isEmpty){
      return "1, 2, 3, 4";
    }
    String prices = "1,";
    List<String> priceList = ["\$", "\$\$", "\$\$\$", "\$\$\$\$"];
    if(userPricePref[0] != "1"){
      prices = "";
    }
    print("userPricePref = " + userPricePref.toString());
    if(userPricePref.isNotEmpty == true) {
      for (int i = 0; i < userPricePref.length; i++) {
        //print("i = " + "\$"*3);
        for(int j = 1; j<5; j++ ){
          print("userPricePref[i] = " + userPricePref[i] + "\nPRICE = " + "\$"*j);
          if(userPricePref[i] == "\$"*j){
            prices += (j.toString() + ",");
          }
        }
      }
      print("prices = " + prices);
      if(prices.endsWith(",")){
        prices = prices.substring(0, prices.length-1);
      }
    }
    //prices += "test";

//    userPricePref = userPricePrefTemp;
//    String temp = "";
//    for(int i = 0; i<userPricePref.length;i++){
//      if(i==0){
//        temp += userPricePref[i];
//      }
//      if(i!=0){
//        temp += userPricePref[i];
//      }
//    }

//    var result = "";
//    if(prices.isNotEmpty) {
//     // print("user price pref = " + temp);
//      var resultList = prices.split("");
//      result = "";
//      if (resultList.isNotEmpty) {
//        result = resultList[0];
//        for (int i = 1; i < resultList.length; i++) {
//          result += ", " + resultList[i];
//        }
////        print("result =" + result);
////        return result;
//      }
//    }
//    else{
//      //return "1, 2, 3, 4";
//      result = "1, 2, 3, 4";
//    }
    if(prices.isEmpty){
      prices = "1, 2, 3, 4";
    }
    return prices;
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
    List<String> _checked = [];
      _isIos = Theme
          .of(context)
          .platform == TargetPlatform.iOS;
      return new Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: new AppBar(
            title: new Text('Find a Restaurant'),
          ),
          body: SingleChildScrollView(
            child: Stack(
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
                padding: const EdgeInsets.fromLTRB(250.0, 200.0, 5.0, 0.0),
                child: Text(
                  'Price Preferences',
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.left,

                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(250.0, 225.0, 0.0, 0.0),
                child: CheckboxGroup(

                  //checked: [],
                  labels: <String>[
                    "\$","\$\$","\$\$\$","\$\$\$\$"
                  ],

                  onSelected: (List<String> selected) => userPricePref = selected,
                  itemBuilder: (Checkbox cb, Text txt, int i){
                    return Column(
                      children: <Widget>[
                        //Icon(Icons.polymer),
                        cb,
                        txt,
                      ],
                    );
                  },


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
//                    Route route = MaterialPageRoute(builder: (context) => YelpSearch(controller.text));
////                    Route route = MaterialPageRoute(builder: (context) => Repository());
//                    Navigator.push(context, route);
                    updatePref();
                  },
                  child: Icon(Icons.search),
                ),
              ),
            ],
          )
          )
      );
    }
}