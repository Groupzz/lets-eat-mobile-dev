import 'package:flutter/material.dart';
import 'signUp2.dart';



class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String _fname;
  String _lname;
  //String _password;

  Widget _showFirstName(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'First Name',
            icon: new Icon(
              Icons.person,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'First Name can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
      ),
    );
  }

  Widget _showLastName(){
    return Padding(
      padding: EdgeInsets.fromLTRB(45.0, 60.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Last Name',
//            icon: new Icon(
//              Icons.,
//              color: Colors.grey,
//            )
            ),
        validator: (value) => value.isEmpty ? 'Last Name can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
      ),
    );
  }

  Widget _showDOB(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 110.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.datetime,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Birthday',
            icon: new Icon(
              Icons.calendar_today,
              color: Colors.grey,
            )
        ),
        validator: (value) => value.isEmpty ? 'Birthday can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
      ),
    );
  }

  Widget _showCity(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 160.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'City',
            icon: new Icon(
              Icons.location_city,
              color: Colors.grey,
            )
        ),
        validator: (value) => value.isEmpty ? 'Birthday can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: ListView(
        children: <Widget>[
          _showFirstName(),
          _showLastName(),
          _showDOB(),
          _showCity(),
          //_showCircularProgress(),
        ],
      )
    );
  }
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//        resizeToAvoidBottomPadding: false,
//        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//          Container(
//            child: Stack(
//              children: <Widget>[
//                Container(
//                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
//                  child: Text(
//                    'Signup Page',
//                    style:
//                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//                  ),
//                ),
//              ],
//            ),
//          ),
//          Container(
//              padding: EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0),
//              child: Column(
//                children: <Widget>[
//                  TextField(
//                    decoration: InputDecoration(
//                        labelText: 'EMAIL',
//                        labelStyle: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            color: Colors.grey,
//                            fontSize: 10.0),
//
//                        // hintText: 'EMAIL',
//                        // hintStyle: ,
//                        focusedBorder: UnderlineInputBorder(
//                            borderSide: BorderSide(color: Colors.green))),
//                  ),
//                  SizedBox(height: 10.0),
//                  TextField(
//                    decoration: InputDecoration(
//                        labelText: 'PASSWORD ',
//                        labelStyle: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            color: Colors.grey,
//                            fontSize: 10.0),
//                        focusedBorder: UnderlineInputBorder(
//                            borderSide: BorderSide(color: Colors.green))),
//                    obscureText: true,
//                  ),
//                  SizedBox(height: 10.0),
//                  TextField(
//                    decoration: InputDecoration(
//                        labelText: 'First Name ',
//                        labelStyle: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            color: Colors.grey,
//                            fontSize: 10.0),
//                        focusedBorder: UnderlineInputBorder(
//                            borderSide: BorderSide(color: Colors.green))),
//                  ),
//                  SizedBox(height: 10.0),
//                  TextField(
//                    decoration: InputDecoration(
//                        labelText: 'Last Name ',
//                        labelStyle: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            color: Colors.grey,
//                            fontSize: 10.0),
//                        focusedBorder: UnderlineInputBorder(
//                            borderSide: BorderSide(color: Colors.green))),
//                  ),
//                  SizedBox(height: 10.0),
//                  TextField(
//                    decoration: InputDecoration(
//                        labelText: 'Date of Birth ',
//                        labelStyle: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            color: Colors.grey,
//                            fontSize: 10.0),
//                        focusedBorder: UnderlineInputBorder(
//                            borderSide: BorderSide(color: Colors.green))),
//                  ),
//                  SizedBox(height: 10.0),
//                  TextField(
//                    decoration: InputDecoration(
//                        labelText: 'City ',
//                        labelStyle: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            color: Colors.grey,
//                            fontSize: 10.0),
//                        focusedBorder: UnderlineInputBorder(
//                            borderSide: BorderSide(color: Colors.green))),
//                  ),
//                  SizedBox(height: 10.0),
//                  Container(
//                      height: 30.0,
//                      child: Material(
//                        borderRadius: BorderRadius.circular(20.0),
//                        shadowColor: Colors.greenAccent,
//                        color: Colors.black,
//                        elevation: 7.0,
//                        child: GestureDetector(
//                          onTap: () {
//                            Route route = MaterialPageRoute(builder: (context) => SignupPage2());
//                            Navigator.push(context, route);
//                          },
//                          child: Center(
//                            child: Text(
//                              'Next',
//                              style: TextStyle(
//                                  color: Colors.white,
//                                  fontWeight: FontWeight.bold,
//                                  ),
//                            ),
//                          ),
//                        ),
//                      )),
//                  SizedBox(height: 10.0),
//                  Container(
//                    height: 20.0,
//                    color: Colors.transparent,
//                    child: Container(
//                      decoration: BoxDecoration(
//                          border: Border.all(
//                              color: Colors.black,
//                              style: BorderStyle.solid,
//                              width: 1.0),
//                          color: Colors.transparent,
//                          borderRadius: BorderRadius.circular(20.0)),
//                      child: InkWell(
//                        onTap: () {
//                          Navigator.of(context).pop();
//                        },
//                        child:
//                            Center(
//                              child: Text('Go Back',
//                                  style: TextStyle(
//                                      fontWeight: FontWeight.bold)),
//                            ),
//                      ),
//                    ),
//                  ),
//                ],
//              )),
//        ])
//    );
 // }
}