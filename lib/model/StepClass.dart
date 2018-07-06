import 'dart:convert';

import 'package:flutter_app/model/CheckList.dart';
import 'package:flutter_app/model/ContentClass.dart';
import 'package:flutter_app/model/ListItem.dart';

class StepClass implements ListItem {
  static final db_id = "id";
  static final db_name = "name";
  static final db_type = "type";
  static final db_checklist_id = "checklist_id";
  static final db_notes = "notes";
  static final db_imagePath = "imagePath";
  static final db_isDone = "isDone";
  static final db_saved_checklist_id = "saved_checklist_id";
  static final db_saved_step_id = "step_id";
  static final columns = [
    db_id,
    db_name,
    db_type,
    db_checklist_id
  ];

  int id;
  String name;
  String type;
  int checklist_id;
  CheckList checklist;
  List<ContentClass> contents;
  String _notes = "";
  String _imageUrl = "";
  String imagePath = "";
  bool isDone = false;

  String get notes => _notes;
  set notes(String notes) {
    _notes = notes;
  }

  String get imageUrl => _imageUrl;
  set imageUrl(String imageUrl) {
    _imageUrl = imageUrl;
  }

  StepClass({this.id, this.name, this.type, this.checklist_id, notes, this.imagePath, this.isDone, this.contents});

  factory StepClass.fromJson(Map<String, dynamic> json) {
    return StepClass(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        checklist_id: json['checklist_id'] as int,
        contents: (json['contents'] as List).map((i) => ContentClass.fromJson(i)).toList()
    );
  }

  StepClass.fromMap(Map<String, dynamic> map): this(
    id: map[db_id],
    name: map[db_name],
    type: map[db_type],
    checklist_id: map[db_checklist_id]
  );

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      db_id: id,
      db_name: name,
      db_type: type,
      db_checklist_id: checklist_id
    };
  }
}