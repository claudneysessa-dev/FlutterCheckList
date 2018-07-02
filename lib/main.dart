import 'package:flutter/material.dart';
import 'package:flutter_app/model/Categories.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'CheckLists',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: new Categories(),
    );
  }
}

