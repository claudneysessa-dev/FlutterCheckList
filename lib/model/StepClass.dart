import 'package:flutter_app/model/ListItem.dart';

class StepClass implements ListItem {
  final int id;
  final String name;
  final String type;
  final String checklist;
  final String content;
  bool isDone = false;

  StepClass({this.id, this.name, this.type, this.checklist, this.content});

  factory StepClass.fromJson(Map<String, dynamic> json) {
    return StepClass(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        checklist: json['checklist'] as String,
        content: json['content'] as String
    );
  }

  String get notes => this.notes;
  set notes(String notes) {
    this.notes = notes;
  }

  String get imageUrl => this.imageUrl;
  set imageUrl(String imageUrl) {
    this.imageUrl = imageUrl;
  }
}