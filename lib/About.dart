import 'package:flutter/material.dart';


class About extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("About Our App"),
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/indexbg.jpg"),
                fit: BoxFit.cover,
              )
          ),
        )
    );
  }
}