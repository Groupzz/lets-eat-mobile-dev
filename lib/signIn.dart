//import 'package:flutter/material.dart';
//
//class SignIn extends MaterialPageRoute<Null> {
//  SignIn(): super(builder: (BuildContext ctx) {
//
//
//  return Scaffold(
//      appBar: AppBar(
//      title: const Text('Sign In'),
//      ),
//      body: Container(
//      color: Colors.white,
//      child: Padding(
//      padding: const EdgeInsets.symmetric(
//      vertical: 8.0,
//      horizontal: 32.0,
//      ),
//      child: Column(
//      children: [
//      Padding(
//      padding: const EdgeInsets.only(bottom: 8.0),
//      child: TextField(
//      decoration: InputDecoration(
//      labelText: 'Email',
//      )),
//      ),
//      Padding(
//      padding: const EdgeInsets.only(bottom: 8.0),
//      child: TextField(
//      obscureText: true,
//      decoration: InputDecoration(
//      labelText: "Password",
//      )),
//      ),
//      Padding(
//      padding: const EdgeInsets.all(16.0),
//      child: Builder(
//      builder: (context) {
//      return RaisedButton(
//      onPressed: () => print('PRESSED'),
//      color: Colors.lightBlue,
//      child: Text('Sign In'),
//      );
//      },
//      ),
//      ),
//      Padding(
//      padding: const EdgeInsets.all(16.0),
//      child: Builder(
//      builder: (context) {
//      return RaisedButton(
//      onPressed: () => print('PRESSED'),
//      color: Colors.lightBlue[200],
//      child: Text('Sign Up'),
//      );
//      },
//      ),
//      ),
//      ],
//      ),
//      ),
//      ),
//      );
//
//
//  })
//}