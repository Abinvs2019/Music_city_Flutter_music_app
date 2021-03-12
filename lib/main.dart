import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter_app2/songs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void homePageChange() async {
      await Future.delayed(const Duration(seconds: 2), () {});
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Songs()));
    }

    homePageChange();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 450, 0, 0),
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      "https://i.pinimg.com/originals/ca/76/0b/ca760b70976b52578da88e06973af542.jpg"),
                ),
              ),
              Divider(
                height: 30,
              ),
              Text(
                "listen to your",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 55,
                    color: Colors.white),
              ),
              Text(
                "Favourites.",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 55,
                    color: Colors.white),
              ),
              Divider(
                height: 30,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
