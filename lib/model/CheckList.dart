import 'dart:convert';

import 'package:flutter_app/model/CategoryClass.dart';
import 'package:flutter_app/model/ListItem.dart';
import 'package:flutter_app/model/StepClass.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

class CheckList implements ListItem {
  static final db_id = "id";
  static final db_name = "name";
  static final db_type = "type";
  static final db_category_id = "category_id";
  static final columns = [db_id, db_name, db_type, db_category_id];

  int id;
  String name;
  String type;
  int category_id;
  CategoryClass category;
  List<StepClass> steps;
  bool alreadySaved = false;
  int saved_checklist_id;
  int _timestamp = new DateTime.now().millisecondsSinceEpoch;
  int get timestamp => _timestamp;
  set timestamp(int t) {
    _timestamp = t;
  }

  humanReadableTime (int t) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(t);
    var format = new DateFormat.yMd().add_jm();
    return format.format(date);
  }

  CheckList({this.id, this.name, this.type, this.steps, this.category_id});

  factory CheckList.fromJson(Map<String, dynamic> json) {
    return CheckList(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      category_id: json['category_id'] as int,
      steps: (json['steps'] as List).map((i) => StepClass.fromJson(i)).toList()
    );
  }

  Map<String, dynamic> toJson() =>
    {
      this.timestamp.toString(): {
        'id': this.id,
        'steps': stepsToJson()
      }
    };

  stepsToJson() {
    var result = [];
    for(StepClass step in this.steps) {
      result.add({"id": step.id, "notes": step.notes, "imageUrl": step.imageUrl, "isDone": step.isDone});
    }
    return json.encode(result);
  }

  CheckList.fromMap(Map<String, dynamic> map): this(
      id: map[db_id],
      name: map[db_name],
      type: map[db_type],
      category_id: map[db_category_id],
  );

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      db_id: id,
      db_name: name,
      db_type: type,
      db_category_id: category_id
    };
  }

  List<Share> toSharable() {
    List<Share> result = new List();
    String info = type + " "
        + name + " "
        + category.name + " "
        + steps.length.toString();
    result.add(Share.plainText(text: info, title: name));
    for (StepClass step in steps) {
      if (step.notes.isNotEmpty) {
        result.add(
            Share.plainText(
                text: step.notes,
                title: step.name
            )
        );
      }

      if (step.imagePath.isNotEmpty) {
        result.add(
            Share.image(
                path: step.imagePath,
                mimeType: ShareType.TYPE_IMAGE,
                title: step.name
            )
        );
      }
    }
    return result;
  }
}