import 'dart:convert';

import 'package:flutter_app/model/ListItem.dart';

class ContentClass implements ListItem {
  static final db_id = "id";
  static final db_name = "name";
  static final db_text = "text";
  static final db_type = "type";
  static final db_step_id = "step_id";
  static final columns = [db_id, db_name, db_text, db_type, db_step_id];

  int id;
  String name;
  String type;
  int step_id;
  String text;

  ContentClass({this.id, this.name, this.type, this.step_id, this.text});

  ContentClass.fromMap(Map<String, dynamic> map): this(
    id: map[db_id],
    name: map[db_name],
    type: map[db_type],
    step_id: map[db_step_id],
    text: map[db_text]
  );

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      db_id: id,
      db_name: name,
      db_type: type,
      db_step_id: step_id,
      db_text: text
    };
  }

  factory ContentClass.fromJson(Map<String, dynamic> json) {
    return ContentClass(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        text: json['text'] as String,
        step_id: json['step_id'] as int
    );
  }
}