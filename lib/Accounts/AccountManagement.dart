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
              child: new Text("Resend link"),
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

  void changeEmail() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Change Email'),
            content: TextField(
              controller: _emailFilter,
              decoration: InputDecoration(hintText: "Type Your New Email"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('SUBMIT'),
                onPressed: () async {
                  if(_emailFilter.text.contains('@') && _emailFilter.text.contains('.', _emailFilter.text.indexOf('@'))){
                    widget.auth.changeEmail(_emailFilter.text.toString());
                    await Future.delayed(const Duration(milliseconds: 700), () {});
                    Navigator.pop(context);
                  }
                  else{
                    showBadEmail();
                  }
                },
              )
            ],
          );
        });
  }

  void changeUsername(){
    Route route = MaterialPageRoute(builder: (context) => UpdateUNamePage());
    Navigator.push(context, route);
  }

  void showBadEmail(){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Email Not Correctly Formatted'),
            content: Text('Please Enter A Valid Email Address'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void showPasswordResetSent(){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Check Your Email'),
            content: Text('We sent you an email with a link to reset your password'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
  void resetPassword(){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Change Password'),
            content: Text('An email with instructions to reset your password will be sent to ${user.email}.  Do you wish to continue?'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              new FlatButton(
                child: new Text('Yes'),
                onPressed: () {
                  widget.auth.sendPasswordResetMail(user.email);
                  Navigator.pop(context);
                  showPasswordResetSent();
                },
              ),
            ],
          );
        });
  }

  Widget _showOptionsTitle() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 0.0),
      child: Text("Account Options:", textAlign: TextAlign.right, style: new TextStyle(fontSize: 24.0, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
    );
  }


  Widget _showButtonList() {
    List<String> settings = [ // List of Account Settings options
      'Change Email',
      'Change User Info',
      'Change Username',
      'Reset Password'];
    List<Function> routes = [ // Functions for corresponding Account Settings Options
      changeEmail,
      changeUserSettings,
      changeUsername,
      resetPassword
    ];
    return new Container(
      padding: EdgeInsets.fromLTRB(15.0, 60.0, 26.0, 26.0),
      child: new ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.black,
          ),
        itemCount: settings.length,
        itemBuilder: (context, index) => InkWell(
          onTap: (){
            routes[index]();
          },
          //padding: EdgeInsets.all(8.0),
          child: Center(child: Text("${settings[index]}", textAlign: TextAlign.right, style: TextStyle(fontSize: 28, color: Colors.grey))),

        ),
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
      body: Stack(
        children: <Widget>[
          _showOptionsTitle(),
          _showButtonList(),
        ],
      )
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

  void changeUserSettings(){
    Route route = MaterialPageRoute(builder: (context) => UpdatePage());
    Navigator.push(context, route);
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