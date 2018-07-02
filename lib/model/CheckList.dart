import 'package:flutter_app/model/ListItem.dart';
import 'package:flutter_app/model/StepClass.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CheckList implements ListItem {
  final int id;
  final String name;
  final String type;
  final String category;
  final List<StepClass> steps;
  bool alreadySaved = false;
  final int timestamp = new DateTime.now().millisecondsSinceEpoch;

  humanReadableTime (int t) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(t);
    var format = new DateFormat.yMd().add_jm();
    return format.format(date);
  }

  CheckList({this.id, this.name, this.type, this.category, this.steps});

  factory CheckList.fromJson(Map<String, dynamic> json) {
    return CheckList(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      steps: (json['steps'] as List).map((i) => StepClass.fromJson(i)).toList()
    );
  }
}