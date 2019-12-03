import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
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

class SignupPage extends StatefulWidget {
  SignupPage({this.auth, this.email, this.pass});

  final BaseAuth auth;
  final String email;
  final String pass;

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
  final stateController = TextEditingController();
  final securityQController = TextEditingController();
  final securityAController = TextEditingController();
  FirebaseUser user;
  QuerySnapshot userData;
  String _errorMessage;
  bool _isIos;
  bool _isLoading;


  @override
  void initState() {
    _isLoading = false;
    _errorMessage = "";
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

  void _updateData() async {
    try {
      var results = Firestore.instance.collection('users').where(
          'username', isEqualTo: uNameController.text // Get current user id
      );

      var querySnap = await results.getDocuments();
      var length = querySnap.documents.length;


      if (uNameController.text.isNotEmpty && length == 0) {
        _userId = await widget.auth.signUp(widget.email, widget.pass);
        Future<DocumentReference> userDoc;

        Firestore.instance.collection('friends').add(
            { // Add user to firestore w/ generated userID
              "id": _userId,
              "friends": [],
            }).then((fDoc) {
          Firestore.instance.collection('preferences').add(
              {
                "id": _userId,
              }
          ).then((pDoc) {
            Firestore.instance.collection('likedRestaurants').add(
                {
                  "id": _userId,
                  "restaurantIDs": [],
                }
            ).then((lDoc) {
              print("Friend ID = " + fDoc.documentID);
              // Add new user to Users collection & include Friends Document ID
              userDoc = Firestore.instance.collection('users').add(
                  {
                    // Add user to firestore w/ generated userID
                    "email": widget.email,
                    "id": _userId,
                    "friendsDocID": fDoc.documentID,
                    // Document ID for current user's Friends document
                    "likedRestaurantsID": lDoc.documentID,
                    "preferencesID": pDoc.documentID,
                    "securityquestion": securityQController.text,
                    "securityanswer": securityAController.text,
                    "state": stateController.text,
                    "firstname": fNameController.text,
                    "lastname": lNameController.text,
                    "username": uNameController.text,
                    "phone": phoneController.text,
                    "dateofbirth": dobController.text,
                    "city": cityController.text,
                    "zip": zipController.text,
                  });
            });
          });
        });

        widget.auth.sendEmailVerification();
        _showVerifyEmailSentDialog();

        user = await FirebaseAuth.instance.currentUser();
        UserUpdateInfo updateInfo = UserUpdateInfo();
        updateInfo.displayName = uNameController.text;
        user.updateProfile(updateInfo);
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();

        _showSuccess();
      }

      else if (uNameController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("You Must Provide a username"),
              content: new Text(
                  "Your account can't be made without a username"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Dismiss"),
                  onPressed: () {
                    //prefix0.Navigator.of(context).pop()
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }

      else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Username already taken"),
              content: new Text("You must pick a unique username"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Dismiss"),
                  onPressed: () {
                    //prefix0.Navigator.of(context).pop()
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
    catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        if (_isIos) {
          _errorMessage = e.details;
        } else
          _errorMessage = e.message;
      });
    }
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

    void _showVerifyEmailSentDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Verify your account"),
            content: new Text(
                "Link to verify account has been sent to your email"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Dismiss"),
                onPressed: () {
                  //prefix0.Navigator.of(context).pop()
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Your Account Has Been Created!"),
          content: new Text("Link to verify account has been sent to your email"),
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

  Widget _showUserName(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: uNameController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Username',
            //prefixText: userData.documents[0]["username"],
            icon: new Icon(
              Icons.perm_identity,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Uame can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
      ),
    );
  }

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

  Widget _showState(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: stateController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'State',
            icon: new Icon(
              Icons.map,
              color: Colors.grey,
            )
        ),
        validator: (value) => value.isEmpty ? 'State can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
      ),
    );
  }

  Widget _showSecurityQuestion(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: securityQController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Security Question',
            icon: new Icon(
              Icons.security,
              color: Colors.grey,
            )
        ),
        validator: (value) => value.isEmpty ? 'Security Question can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
      ),
    );
  }

  Widget _showSecurityAnswer(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: securityAController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Answer',
            icon: new Icon(
              Icons.question_answer,
              color: Colors.grey,
            )
        ),
        validator: (value) => value.isEmpty ? 'Security Answer can\'t be empty' : null,
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
        padding: EdgeInsets.fromLTRB(20.0, 150.0, 20.0, 40.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Register',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              _updateData();

              setState(() {
                _isLoading = true;
              });
            },

          ),
        ));
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);

  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
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
          _showUserName(),
          _showPhone(),
          _showCircularProgress(),
          _showDOB(),
          _showCity(),
          _showState(),
          _showSecurityQuestion(),
          _showSecurityAnswer(),
          _showZIP(),
          _showPrimaryButton(),
          _showErrorMessage(),


          //_showCircularProgress(),
        ],
      )
    );
  }
}