import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Group{
  final List<String> participants;
  final String uid;
  final String documentID;

  Group.fromSnapshot(DocumentSnapshot snapshot)
      : participants = List.from(snapshot["Participants"]),
        uid = snapshot['creatorID'],
        documentID = snapshot.documentID;


  Group(
      {this.participants,
        this.uid,
        this.documentID});

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