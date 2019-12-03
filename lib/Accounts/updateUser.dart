import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'LoginSignUp.dart';
import 'authentication.dart';
import 'accounts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class UpdatePage extends StatefulWidget {

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String _fname;
  String _lname;
  String userDocID;
  final _formKey = new GlobalKey<FormState>();
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  //String _password;
  String _userId = "";
  final fNameController = TextEditingController();
  final lNameController = TextEditingController();
  final uNameController = TextEditingController();
  final dobController = TextEditingController();
  final cityController = TextEditingController();
  final zipController = TextEditingController();
  final phoneController = TextEditingController();
  FirebaseUser user;
  QuerySnapshot userData;


  @override
  void initState() {
    super.initState();
//    widget.auth.getCurrentUser().then((user) {
//      setState(() {
//        if (user != null) {
//          _userId = user?.uid;
//        }
//        authStatus =
//        user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
//      });
//    });
  }


  void _getCurrentUser() async {
    user = await FirebaseAuth.instance.currentUser();
    _userId = user.uid;
    Firestore.instance.collection('users').where(
        'id', isEqualTo: _userId // Get current user id
    ).snapshots().listen(
      // Update Friends collection that contains current user ID
            (data) => userData = data);
    //userDocID = data.documents[0].documentID);
    await Future.delayed(const Duration(milliseconds: 700), (){});
    userDocID = userData.documents[0].documentID;

  }

  void _updateData() async{
//    Firestore.instance.collection('users').where(
//        'id', isEqualTo: _userId // Get current user id
//    ).snapshots().listen(
//      // Update Friends collection that contains current user ID
//            (data) =>
//        userDocID = data.documents[0].documentID).onDone(
//      _updatePrefs
//    );
    print("user id = " + userDocID);

    Firestore.instance.collection('users').document(userDocID).updateData({
      "firstname": fNameController.text,
      "lastname": lNameController.text.isEmpty? userData.documents[0]["lastname"].toString() : lNameController.text,
      "phone": phoneController.text.isEmpty? userData.documents[0]["phone"].toString() : phoneController.text,
      "dateofbirth": dobController.text.isEmpty? userData.documents[0]["dateofbirth"].toString() : dobController.text,
      "city": cityController.text.isEmpty? userData.documents[0]["city"].toString() : cityController.text,
      "zip" : zipController.text.isEmpty? userData.documents[0]["zip"].toString() : zipController.text,
    }
    );

    _showSuccess();
  }
  void _showSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Your Account Has Been Updated!"),
          //content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Widget _showFirstName(){
    _getCurrentUser();
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: fNameController,
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
      padding: EdgeInsets.fromLTRB(45.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: lNameController,
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

//  Widget _showUserName(){
//    return Padding(
//      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
//      child: new TextFormField(
//        controller: uNameController,
//        maxLines: 1,
//        keyboardType: TextInputType.text,
//        autofocus: false,
//        decoration: new InputDecoration(
//            hintText: 'Username',
//            //prefixText: userData.documents[0]["username"],
//            icon: new Icon(
//              Icons.perm_identity,
//              color: Colors.grey,
//            )),
//        validator: (value) => value.isEmpty ? 'Uame can\'t be empty' : null,
//        onSaved: (value) => _fname = value.trim(),
//      ),
//    );
//  }

  Widget _showDOB(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: dobController,
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
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: cityController,
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
        validator: (value) => value.isEmpty ? 'City can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
      ),
    );
  }

  Widget _showPhone(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: phoneController,
        maxLines: 1,
        keyboardType: TextInputType.phone,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Phone Number',
            icon: new Icon(
              Icons.phone,
              color: Colors.grey,
            )
        ),
        validator: (value) => value.isEmpty ? 'Phone can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
      ),
    );
  }

  Widget _showZIP(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: zipController,
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Zipcode',
            icon: new Icon(
              Icons.location_on,
              color: Colors.grey,
            )
        ),
        validator: (value) => value.isEmpty ? 'Zipcode can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
      ),
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20.0, 45.0, 20.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Update Account',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _updateData,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentUser();
    // TODO: implement build
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("Update Account"),
        ),
        body: ListView(
          children: <Widget>[
            _showFirstName(),
            _showLastName(),
//          _showUserName(),
            _showPhone(),
            _showDOB(),
            _showCity(),
            _showZIP(),
            _showPrimaryButton(),
            //_showCircularProgress(),
          ],
        )
    );
  }
}