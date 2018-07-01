import 'dart:async';
import 'package:flutter_app/data/category_parser.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
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

