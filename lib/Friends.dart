import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Friends{
  final List<String> friends;
  final String uid;

  Friends.fromSnapshot(DocumentSnapshot snapshot)
      : friends = List.from(snapshot["friends"]),
        uid = snapshot['userID'];


  Friends(
      {this.friends,
        this.uid});

//  factory Friends.fromJson(Map<String, dynamic> json) {
//    return Friends(
//      firstName: json['firstName'],
//      lastName: json['lastName'],
//      username: json['username'],
//      id: json['id'],
//      email: json['email'],
//    );
//  }
}