import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class About extends StatelessWidget{

  final feedbackController = TextEditingController();

  Widget answerBuilder(BuildContext context, About_entry entry){
    return SimpleDialog(contentPadding: EdgeInsets.zero,
        children: [

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(entry.answer)
            ],
          )
        )]);
  }

  Widget aboutListBuilder(BuildContext context, int index){
    return new GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => answerBuilder(context, about_list[index])
      ),
    child: Container(
        padding: const EdgeInsets.only(left: 16),
        alignment: Alignment.centerLeft,
          child: Text(about_list[index].question,
      style: Theme.of(context).textTheme.headline)
      )
    );
  }

//  Widget showFeedbackButton(){
//    return RaisedButton(
//      elevation: 5.0,
//      shape: new RoundedRectangleBorder(
//          borderRadius: new BorderRadius.circular(30.0)),
//      color: Colors.blue,
//      child: new Text('Send Feedback',
//          style: new TextStyle(
//              fontSize: 16.0, color: Colors.white)),
//      onPressed: () {
//        _displayAddPref();
//      },
//    );
//  }
//  void _displayAddPref() async {
//    return showDialog(
//        context: context,
//        builder: (context) {
//          return AlertDialog(
//            title: Text('Feedback'),
//            content: TextField(
//              controller: feedbackController,
//              decoration: InputDecoration(hintText: "Type Your Feedback"),
//            ),
//            actions: <Widget>[
//              new FlatButton(
//                child: new Text('SUBMIT'),
//                onPressed: () {
//                  // Send new preference to group vote document
//                  Firestore.instance.collection('feedback').add({"UserFeedback":feedbackController.text});
//                  feedbackController.clear();
//                  Navigator.of(context).pop();
//                  showDialog(
//                      context: context,
//                      builder: (context) {
//                        return AlertDialog(
//                          title: Text("Thanks, your feedback has been received!"),
//                          actions: <Widget>[
//                            new FlatButton(
//                              child: new Text("Dismiss"),
//                              onPressed: () {
//                                Navigator.of(context).pop();
//                              },
//                            )
//                          ],
//                        );
//                      }
//                  );
//                },
//              )
//            ],
//          );
//        });
//  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("About Our App"),
        ),
        body: Stack(
            children: <Widget>[
                ListView.builder(
                itemCount: about_list.length,
                itemExtent: 60.0,
                itemBuilder: aboutListBuilder,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(100.0, 250.0, 50.0, 20.0),
          child:RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.blue,
          child: new Text('Send Feedback',
              style: new TextStyle(
                  fontSize: 16.0, color: Colors.white)),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Feedback'),
                    content: TextField(
                      controller: feedbackController,
                      decoration: InputDecoration(hintText: "Type Your Feedback"),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text('SUBMIT'),
                        onPressed: () {
                          // Send new preference to group vote document
                          Firestore.instance.collection('feedback').add({"UserFeedback":feedbackController.text});
                          feedbackController.clear();
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Thanks, your feedback has been received!"),
                                  actions: <Widget>[
                                    new FlatButton(
                                      child: new Text("Dismiss"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              }
                          );
                        },
                      )
                    ],
                  );
                });
          },
        )
        )]
    ));
  }
}

class About_entry{
  const About_entry({this.question,this.answer});

  final String question;
  final String answer;
}
final List<About_entry> about_list = <About_entry>[
  About_entry(
    question: 'What is Let\'s Eat! and its features?',
    answer: 'Let\'s Eat! is an application that helps users decide what their next meal'
  ' is going to be. Sometimes it seems like there are way too many food options to'
  ' decide on. With Let\'s Eat!, you are guaranteed to find a restaurant nearby that'
  ' satisfies your needs.'
  ),
  About_entry(
      question: 'Why are some places further than my max distance?',
      answer: 'In order to find you the best restaurants possible, we sometimes consider highly ranked restauranats that fall a mile or so outside of your specified range\n'
  ),
  About_entry(
      question: 'Why am I getting an error when trying to find a restaurant?',
      answer: 'If you are applying many filters, the app will try and find a restaurant that satisfies all specified filters.\n\nTry modifying your filters; If your specified filters are too strict, there may be no restaurants around you that match all the criteria.'
  ),
  About_entry(
      question: 'I found a bug!',
      answer: 'Oh no!  Please use the \'Send Feedback\' button below to let us know what happened.  Please include steps to reproduce the issue if possible'
  ),
];

final String git_url = 'https://github.com/Groupzz/lets-eat-mobile-dev';