import 'package:flutter/material.dart';
import 'package:lets_eat/YelpSearch.dart';
import 'package:lets_eat/YelpRepository.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';

class UserYelpPreferences extends StatefulWidget
{
  @override
  UserYelpPreferencesState createState() {
    return UserYelpPreferencesState();
  }
}

class UserYelpPreferencesState extends State<UserYelpPreferences> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  final locationController = TextEditingController();
  String _query;
  bool _isIos;
  var cuisineListEthnic = ["American","Mexican","Japanese","Korean","Chinese","Indian","Thai","Mediterranean","Italian","French"];
  var dietaryRestrictions = ["Vegetarian","Vegan","Halal","Pescetarian"];
  var pricepointList = [1,2,3,4];
  double _sliderValue = 10.0;

  List<dynamic> userCuisinePref = [];
  List<String> userPricePref = [];
  List<String> userDietPref = [];
  List<String> openNow = [];
  String cuisineURL="";
  String priceURL="";
  //String _picked = "";

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
        query = "term=" + cuisineURL;
      }

      if(locationController.text.isNotEmpty){
        query += "&location="+locationController.text;
      }

      double meters = _sliderValue.toInt()*1609.34;
      if(meters > 40000.0){
        meters = 40000;
      }
      if(query.length > 0){
        query += "&";
      }
      query += "radius=" + meters.toInt().toString() + "&";

      query += "price=" + priceURL;


      if(openNow.length > 0){
        query += "&open_now=true";
      }

      //query += "+price"

      print("query = " + query);

      //TODO Save preferences
    }
    else
    {
      String query = "term=" + controller.text;
      if(cuisineURL.isNotEmpty){
        query += "+" + cuisineURL;
      }

      if(locationController.text.isNotEmpty){
        query += "&location="+locationController.text;
      }
      //+ "+" + cuisineURL;

      double meters = _sliderValue.toInt()*1609.34;
      if(meters > 40000.0){
        meters = 40000;
      }
      query += "&radius=" + meters.toInt().toString();

      if(priceURL.isNotEmpty)
      {
        query += "&price=" + priceURL;
      }

      if(openNow.length > 0){
        query += "&open_now=true";
      }




      print("query = " + query);
//      Route route = MaterialPageRoute(builder: (context) => YelpSearchPage(query: query));
////                    Route route = MaterialPageRoute(builder: (context) => Repository());
//      Navigator.push(context, route);
    }

  }


  //Converts cuisine list into URL ready string
  String parseCuisine(){
    String temp = "";
    if(userCuisinePref == null){
      return "";
    }
    else {
      for (int i = 0; i < userCuisinePref.length; i++) {
        if (i == 0) {
          temp = temp + userCuisinePref[i];
        }
        if (i != 0) {
          temp = temp + "+" + userCuisinePref[i];
        }
      }
      return temp;
    }
  }

  String parsePrice(){ //Converts dollar signs to string ints and return URL ready string
    //List<String> userPricePrefTemp = new List(userPricePref.length);
    if(userPricePref.isEmpty){
      return "1, 2, 3, 4";
    }
    String prices = userPricePref[0].length.toString();
    List<String> priceList = ["\$", "\$\$", "\$\$\$", "\$\$\$\$"];
//    if(userPricePref[0] != "1"){
//      prices = "";
//    }
    //userPricePref.sort((a,b) => a.length.compareTo(b.length));
    print("userPricePref = " + userPricePref.toString());
    for(int i = 1; i < userPricePref.length; i++){
      prices += ", " + userPricePref[i].length.toString();
    }
//    if(userPricePref.isNotEmpty == true) {
//      for (int i = 0; i < userPricePref.length; i++) {
//        //print("i = " + "\$"*3);
//        for(int j = 1; j<5; j++ ){
//          print("userPricePref[i] = " + userPricePref[i] + "\nPRICE = " + "\$"*j);
//          if(userPricePref[i] == "\$"*j){
//            prices += (j.toString() + ",");
//          }
//        }
//      }
//
//      if(prices.endsWith(",")){
//        prices = prices.substring(0, prices.length-1);
//      }
//    }
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
    print("prices = " + prices);
    if(prices.isEmpty){
      prices = "1, 2, 3, 4";
    }
    return prices;
  }


  Widget _showDistanceSlider(){
    return Padding(
        padding: const EdgeInsets.fromLTRB(70, 370, 80.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 1,
              // A slider, like many form elements, needs to know its
              // own value and how to update that value.
              //
              // The slider will call onChanged whenever the value
              // changes. But it will only repaint when its value property
              // changes in the state using setState.
              //
              // The workflow is:
              // 1. User drags the slider.
              // 2. onChanged is called.
              // 3. The callback in onChanged sets the sliderValue state.
              // 4. Flutter repaints everything that relies on sliderValue,
              // in this case, just the slider at its new value.
              child: Slider(
                activeColor: Colors.indigoAccent,
                min: 1.0,
                max: 25.0,
                divisions: 5,
                onChanged: (newRating) {
                  setState(() => _sliderValue = newRating);
                },
                value: _sliderValue,
              ),
            ),
            Container(
              width: 50.0,
              alignment: Alignment.center,
              child: Text('${_sliderValue.toInt()} mi.',
                  style: Theme.of(context).textTheme.display1,
                  textScaleFactor: .6),
            ),
          ],
        ));
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(90.0, 500.0, 0.0, 30.0),
        child: SizedBox(
          height: 40.0,
          width: 200.0,
          child: new RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.blue,
              child: new Text('Search',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: updatePref
          ),
        ));
  }


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
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 125.0, 0.0, 0.0),
                  child: MultiSelect(
                      autovalidate: true,
                      titleText: 'Food Categories',
                      validator: (value) {
                        userCuisinePref = value;
                        print("User prefs = " + userCuisinePref.toString());
                      },
                      errorText: 'Please select one or more option(s)',
                      dataSource: [
                        {
                          "display": "American",
                          "value": "American",
                        },
                        {
                          "display": "Mexican",
                          "value": "Mexican",
                        },
                        {
                          "display": "Italian",
                          "value": "Italian",
                        },
                        {
                          "display": "Chinese",
                          "value": "Chinese",
                        },
                        {
                          "display": "Japanese",
                          "value": "Japanese",
                        },
                        {
                          "display": "Thai",
                          "value": "Thai",
                        },
                        {
                          "display": "Indian",
                          "value": "Indian",
                        },
                        {
                          "display": "French",
                          "value": "French",
                        },
                        {
                          "display": "Vegetarian",
                          "value": "Vegetarian",
                        },
                        {
                          "display": "Vegan",
                          "value": "Vegan",
                        },
                      ],
                      textField: 'display',
                      valueField: 'value',
                      filterable: true,
                      maxLength: 5,
                      required: false,
                      value: null,
                      onSaved: (value) {
                        print('The value is ');
                      }
                  ),
//                child: CheckboxGroup(
//                  labels: cuisineListEthnic,
//                  onSelected: (List<String> selected) => userCuisinePref = selected,
//                ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(100.0, 350.0, 5.0, 0.0),
                  child: Text(
                    'Max Distance:',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.left,

                  ),
                ),
                _showDistanceSlider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(80.0, 420, 5.0, 0.0),
                  child: CheckboxGroup(
                    orientation: GroupedButtonsOrientation.VERTICAL,
                    margin: const EdgeInsets.only(left: 12.0),
                    onSelected: (List<String> selected) => openNow = selected,
                    labels: <String>[
                      "Open Now"
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(100.0, 230.0, 5.0, 0.0),
                  child: Text(
                    'Price Preferences:',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.left,

                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(80.0, 260.0, 5.0, 0.0),
                  child: CheckboxGroup(

                    //checked: [],
                    orientation: GroupedButtonsOrientation.HORIZONTAL,
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
                _showPrimaryButton(),
//              Padding(
//                padding: const EdgeInsets.fromLTRB(300.0, 500.0, 0.0, 0.0),
//                child: RaisedButton(
//                  onPressed: () {
//                    //print("puery = " + _query);
//                    // Validate returns true if the form is valid, or false
//                    // otherwise.
//
//                      // If the form is valid, display a Snackbar.
////                    Route route = MaterialPageRoute(builder: (context) => YelpSearch(controller.text));
//////                    Route route = MaterialPageRoute(builder: (context) => Repository());
////                    Navigator.push(context, route);
//                    updatePref();
//                  },
//                  child: Icon(Icons.search),
//                ),
//              ),
              ],
            )
        )
    );
  }
}