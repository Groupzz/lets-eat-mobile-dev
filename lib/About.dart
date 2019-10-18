import 'package:flutter/material.dart';


class About extends StatelessWidget{

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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("About Our App"),
        ),
        body: ListView.builder(
            itemCount: about_list.length,
            itemExtent: 60.0,
            itemBuilder: aboutListBuilder,
        ),
    );
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
    answer: 'Let\'s Eat! is an application that assists users in deciding what their next meal'
  ' is going to be. Sometimes it seems like there are way too many food options to'
  ' decide on. With Let\'s Eat!, you are guaranteed to find a restaurant nearby that'
  ' satisfies your needs.'
  ),
  About_entry(
      question: 'How to Install?',
      answer: 'For android, we don\'t know yet'
  ),
  About_entry(
      question: 'What are the components?',
      answer: 'We are using Flutter in Android Studio for the main app development and Firebase for our account database.'
  ),
  About_entry(
      question: 'How to contribute?',
      answer: 'Our source code is located on Github'
      ' It is organized by folders that indicate where to find source code for certain aspects of our application.'
      'Feel free to contribute to our source code by cloning our repository and making changes on your local machine.'
  ),
  About_entry(
      question: 'What is the support you provide?',
      answer: 'We offer technical support for users who may have difficulty navigating our app.'
      ' We are always open to suggestions from fellow developers as to how our mobile'
      ' application can be improved or ideas for new features for current and future users to enjoy.'
  ),
  About_entry(
      question: 'Where can I get an API Key for Yelp?',
      answer: 'You need to create a Yelp account or sign in, go to Manage App'
      ' page from their website, then you will receive an email with your API Key.'
  ),
];

final String git_url = 'https://github.com/Groupzz/lets-eat-mobile-dev';