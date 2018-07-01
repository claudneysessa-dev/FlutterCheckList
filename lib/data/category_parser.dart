import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/model/CategoryClass.dart';
import 'package:flutter_app/model/ListItem.dart';

import 'package:flutter/services.dart' show rootBundle;

Future<String> _loadCategoryAsset() async {
  return await rootBundle.loadString('assets/categories.json');
}

Future<List<CategoryClass>> fetchCategories() async {
  String jsonCategory = await _loadCategoryAsset();
  return compute(parseCategories, jsonCategory);
}

List<CategoryClass> parseCategories(String jsonString) {
  final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
  return parsed.map<CategoryClass>((json) => CategoryClass.fromJson(json)).toList();
}

