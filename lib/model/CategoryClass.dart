import 'dart:async';

import 'package:flutter_app/model/ListItem.dart';

import '../model/CheckList.dart';

class CategoryClass implements ListItem {
  static final db_id = "id";
  static final db_name = "name";
  static final db_type = "type";
  static final columns = [db_id, db_name, db_type];

  int id;
  String name;
  String type;
  List<CheckList> checkLists;

  CategoryClass({this.id, this.name, this.type, this.checkLists});

  factory CategoryClass.fromJson(Map<String, dynamic> json) {
    return CategoryClass(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        checkLists: (json['checklists'] as List).map((i) => CheckList.fromJson(i)).toList()
    );
  }

  CategoryClass.fromMap(Map<String, dynamic> map): this(
    id: map[db_id],
    name: map[db_name],
    type: map[db_type]
  );

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      db_id: id,
      db_name: name,
      db_type: type
    };
  }

}