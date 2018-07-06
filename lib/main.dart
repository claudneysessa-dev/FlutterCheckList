import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/model/Categories.dart';

void main() => runApp(new MyApp());

//TODO Implement something that allows admin to add more checklists

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return new MaterialApp(
      title: 'CheckLists',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: new Categories(),
    );
  }
}

