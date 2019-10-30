import 'package:flutter/material.dart';
import 'authentication.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsPage extends StatefulWidget {
  FriendsPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {

  bool _isIos;
  bool _isLoading;
  String _errorMessage;
  String _friendUName;

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void addFriend() async
  {

  }

  Widget _addFriendField()
  {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Enter Username of the Friend You Want To Add',
            icon: new Icon(
              Icons.person_add,
              color: Colors.grey,
            )
        ),
        validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
        onSaved: (value) => _friendUName = value.trim(),
      ),
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(300.0, 70.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Add Friend',
                style: new TextStyle(fontSize: 16.0, color: Colors.white)),
              onPressed: _addFriendField
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Friends'),
        ),
        body: Stack(
          children: <Widget>[
            _addFriendField(),
            _showPrimaryButton(),
          ],
        ));
  }

}