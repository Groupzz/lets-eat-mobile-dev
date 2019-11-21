/**
 * References: https://medium.com/@abeythilakeudara3/firebase-authentication-with-flutter-d403bf39a029
 * https://medium.com/flutterpub/flutter-how-to-do-user-login-with-firebase-a6af760b14d5
 * https://github.com/delay/flutter_firebase_auth_example
 */
import 'package:flutter/material.dart';
import 'LoginSignUp.dart';
import 'authentication.dart';
import 'accounts.dart';

class LoginRootPage extends StatefulWidget {
  LoginRootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _LoginRootPageState();
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _LoginRootPageState extends State<LoginRootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  String _username = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
          _username = user?.displayName;
        }
        authStatus =
        user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user){
      setState(() {
        _userId = user.uid.toString();
        _username = user.displayName;
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;

    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignUpPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return new Accounts(
            userId: _userId,
            username: _username,
            auth: widget.auth,
            onSignedOut: _onSignedOut,
          );
        } else return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}