import 'package:flutter_app/model/ListItem.dart';

import '../model/CheckList.dart';

class CategoryClass implements ListItem {
  final int id;
  final String name;
  final String type;
  final List<CheckList> checkLists;

  CategoryClass({this.id, this.name, this.type, this.checkLists});

  factory CategoryClass.fromJson(Map<String, dynamic> json) {
    return CategoryClass(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        checkLists: (json['checklists'] as List).map((i) => CheckList.fromJson(i)).toList()
    );
  }
}