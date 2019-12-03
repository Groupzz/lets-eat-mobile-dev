import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lets_eat/Accounts/updateUser.dart';
import 'authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'updateUName.dart';
import 'signUpPage.dart';

class AccountManagement extends StatefulWidget {
  AccountManagement({Key key, this.auth, this.userId, this.username, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;
  final String username;

  @override
  State<StatefulWidget> createState() => new _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement> {

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference itemRef;
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _usernameFilter = new TextEditingController();
  final TextEditingController _resetPasswordEmailFilter =
  new TextEditingController();
  FirebaseUser user;
  String uid;

  String _email = "";
  String _username = "";
  String _resetPasswordEmail = "";
  String _userId;

  String _errorMessage;
  bool _isIos;
  bool _isLoading;

  _AccountsState() {
    _emailFilter.addListener(_emailListen);
    //_usernameFilter.addListener(_usernameListen);
    _resetPasswordEmailFilter.addListener(_resetPasswordEmailListen);
  }

  void _resetPasswordEmailListen() {
    if (_resetPasswordEmailFilter.text.isEmpty) {
      _resetPasswordEmail = "";
    } else {
      _resetPasswordEmail = _resetPasswordEmailFilter.text;
    }
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

//  void _usernameListen() {
//    if (_usernameFilter.text.isEmpty) {
//      _username = "";
//    } else {
//      _username = _usernameFilter.text;
//    }
//  }

  //Query _todoQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    //getCurrentUserInfo();
    super.initState();
    //print("usernameefw =" + widget.username);
    //getCurrentUserInfo();
    itemRef = _database.reference().child('users');
    _checkEmailVerification();
  }

  void _checkEmailVerification() async {
    user = await FirebaseAuth.instance.currentUser();
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
          new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailFilter.dispose();
    _usernameFilter.dispose();
    _resetPasswordEmailFilter.dispose();
    super.dispose();
  }


  Widget _showButtonList() {
    return new Container(
      padding: EdgeInsets.all(26.0),
      child: new ListView(
        children: <Widget>[
          _showChangeEmailContainer(),
          _changeUserInfoContainer(),
          new SizedBox(
            height: 40.0,
          ),
          _showChangeUsernameContainer(),
          new SizedBox(
            height: 40.0,
          ),
          _showSentResetPasswordEmailContainer(),
          new SizedBox(
            height: 40.0,
          ),
          _removeUserContainer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    //widget.onSignedOut();
    //getCurrentUserInfo();

    print("userid = " + widget.userId);
    String displayUName = widget.username ?? "user";
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Hello, ' + displayUName),
//        title: new Text('Hello, '),
      ),
      body: _showButtonList(),
    );
  }

  Widget _showEmailChangeErrorMessage() {
    if (_errorMessage != null) {
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

  _showChangeEmailContainer() {
    return Container(
//      decoration: BoxDecoration(
//        borderRadius: new BorderRadius.circular(30.0),
//        color: Colors.amberAccent,
//      ),
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Column(
        children: <Widget>[
          new TextFormField(
            controller: _emailFilter,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Enter New Email",
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
            ),
          ),
          new MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () {
              // widget.auth.changeEmail("abc@gmail.com");
              _changeEmail();
            },
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            color: Colors.blueAccent,
            textColor: Colors.white,
            child: Text(
              "Change Email",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _changeEmail() {
    if (_email != null && _email.isNotEmpty) {
      try {
        print("============>" + _email);
        widget.auth.changeEmail(_email);
      } catch (e) {
        print("============>" + e);
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    } else {
      print("email feild empty");
    }
  }

  void _changeUsername() async{
    String userDoc;
    Firestore.instance.collection('users').where(
        'id', isEqualTo: widget.userId // Get current user id
    ).snapshots().listen(
      // Update Friends collection that contains current user ID
            (data) => userDoc = data.documents[0].documentID
    );

    Firestore.instance.collection("users").document(userDoc)
        .updateData({'username': _usernameFilter.text});
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = _usernameFilter.text;
    user.updateProfile(updateInfo);

  }

  void _removeUser() {
    widget.auth.deleteUser();
  }

  void _sendResetPasswordMail() {
    if (_resetPasswordEmail != null && _resetPasswordEmail.isNotEmpty) {
      print("============>" + _resetPasswordEmail);
      widget.auth.sendPasswordResetMail(_resetPasswordEmail);
    } else {
      print("password feild empty");
    }
  }

  _showChangeUsernameContainer() {
    return Container(
//      decoration: BoxDecoration(
//          borderRadius: BorderRadius.circular(30.0),
//          color: Colors.brown
//      ),
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Column(
        children: <Widget>[
//          new TextFormField(
//            controller: _usernameFilter,
//            decoration: new InputDecoration(
//              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//              hintText: "Enter New Username",
//              border:
//              OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
//            ),
//          ),
          new MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (context) => UpdateUNamePage());
              Navigator.push(context, route);
            },
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            color: Colors.blueAccent,
            textColor: Colors.white,
            child: Text(
              "Change Username",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  _showSentResetPasswordEmailContainer() {
    return Column(
      children: <Widget>[
        new Container(
          child: new TextFormField(
            controller: _resetPasswordEmailFilter,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Enter Email",
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
            ),
          ),
        ),
        new MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          onPressed: () {
            _sendResetPasswordMail();
          },
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          color: Colors.blueAccent,
          textColor: Colors.white,
          child: Text(
            "Send Password Reset Mail",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  _removeUserContainer() {
    return new MaterialButton(
      shape:
      RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Are You Sure You Want To Delete Your Account?"),
              content: new Text("This cannot be undone"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text("Yes", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    _removeUser();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      },
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      color: Colors.red,
      textColor: Colors.white,
      child: Text(
        "Delete My Account",
        textAlign: TextAlign.center,
      ),
    );
  }

  _changeUserInfoContainer() {
    return new MaterialButton(
      shape:
      RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      onPressed: (){
        Route route = MaterialPageRoute(builder: (context) => UpdatePage());
        Navigator.push(context, route);
      },
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      color: Colors.blue,
      textColor: Colors.white,
      child: Text(
        "Change User Info",
        textAlign: TextAlign.center,
      ),
    );
  }
}