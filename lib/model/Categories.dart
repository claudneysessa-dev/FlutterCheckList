import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/EditCheckList.dart';
import 'package:flutter_app/data/category_parser.dart';
import 'package:flutter_app/model/CategoryClass.dart';
import 'package:flutter_app/model/CheckList.dart';
import 'package:flutter_app/model/ListItem.dart';

class Categories extends StatefulWidget {
  final List<CategoryClass> categories;

  Categories({Key key, this.categories}) : super(key: key);

  @override
  createState() => new CategoryState();
}

class CategoryState extends State<Categories> {
  final _saved = new Set<CheckList>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  File jsonFile;
  Directory dir;
  String fileName = "savedCheckLists.json";
  bool fileExists = false;
  List<dynamic> fileContent;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) async {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) this.setState(() => fileContent = jsonDecode(jsonFile.readAsStringSync()));
      if (fileContent != null) {
        List<CategoryClass> categories = await fetchCategories();
        fileContent.forEach((savedCheckList) {
          Map<String, dynamic> obj = savedCheckList as Map<String, dynamic>;
          String timestamp;
          int checkListId;
          List<dynamic> stepsData = new List<dynamic>();
          obj.forEach((t, objData) {
            timestamp = t;
            Map<String, dynamic> objDataData = objData;
            objDataData.forEach((key, value) {
              if (key == "id"){
                checkListId = value;
              } else if (key == "steps") {
                stepsData = jsonDecode(value);
              }
            });
          });
          categories.forEach((category) {
            category.checkLists.forEach((checkList) {
              if (checkList.id == checkListId) {
                checkList.timestamp = int.parse(timestamp);
                checkList.alreadySaved = true;
                checkList.steps.forEach((step) {
                  stepsData.forEach((stepData) {
                    if (step.id == stepData["id"]) {
                      step.imageUrl = stepData["imageUrl"];
                      step.notes = stepData["notes"];
                      step.isDone = stepData["isDone"];
                    }
                  });
                });
                _saved.add(checkList);
              }
            });
          });
        });
      }
      if (_saved.isNotEmpty) setState(() {});
    });
  }

  void createFile(Map<String, dynamic> content, Directory dir, String fileName) {
    print("Creating Saved CheckLists file!");
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(jsonEncode([content]));
  }

  void writeToFile(CheckList checklist) {
    print("Writing to Saved CheckLists file!");
    Map<String, dynamic> content = checklist.toJson();
    if (fileExists) {
      print("File exists");
      List<dynamic> jsonFileContent = jsonDecode(jsonFile.readAsStringSync());
      jsonFileContent.add(content);
      jsonFile.writeAsStringSync(jsonEncode(jsonFileContent));
    } else {
      print("File does not exist!");
      createFile(content, dir, fileName);
    }
    this.setState(() => fileContent = jsonDecode(jsonFile.readAsStringSync()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Categories')
      ),
      body: _buildCheckLists(),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: _addCheckList
      ),
    );
  }

  Widget _buildCheckLists() {
    if (_saved.isEmpty) return Container();
    final tiles = _saved.map((checklist) => _buildRow(checklist));
    final divided = ListTile
        .divideTiles(
          context: context,
          tiles: tiles,
        )
        .toList();
    return divided.isNotEmpty
        ? new ListView(children: divided)
        : Container();
  }

  void _addCheckList() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Choose CheckList'),
            ),
            body: _buildCategories(),
          );
        },
      ),
    );
  }

  void _editCheckList(CheckList checkList) {

    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Edit ' + checkList.name),
            ),
            body: new EditCheckList(checkList: checkList,)
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return FutureBuilder<List<CategoryClass>>(
      future: fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        var temp = snapshot.data;
        if (temp != null) {
          final tiles = temp.map((tcat) => _buildRow(tcat));
          final divided = ListTile
              .divideTiles(
            context: context,
            tiles: tiles,
          )
              .toList();

          return snapshot.hasData
              ? new ListView(children: divided)
              : Center(child: CircularProgressIndicator());
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildRow(ListItem tcat) {
    if (tcat.type == "category") {
      CategoryClass category = tcat;
      return new ExpansionTile(
        key: new PageStorageKey<CategoryClass>(category),
        title: new Text(category.name),
        children: category.checkLists.map((tcheck) => _buildRow(tcheck)).toList(),
      );
    } else {
      CheckList checkList = tcat;
      return new ListTile(
        title: new Text(
          checkList.name,
          style: _biggerFont,
        ),
        subtitle: new Text(
          checkList.category
        ),
        trailing: new Text(
          checkList.humanReadableTime(checkList.timestamp)
        ),
        onTap: () {
          setState(() {
            if (!checkList.alreadySaved) {
              //save to _saved list
              checkList.alreadySaved = true;
              writeToFile(checkList);
              _saved.add(checkList);
              Navigator.pop(context);
            } else {
              //open for edit
              _editCheckList(checkList);
            }
          });
        },
      );
    }
  }

//  Widget _buildRowOld(WordPair pair) {
//    return new ListTile(
//      title: new Text(
//        pair.asPascalCase,
//        style: _biggerFont,
//      ),
//      onTap: () {
//        setState(() {
//          _saved.add(pair);
//          Navigator.pop(context);
//        });
//      },
//    );
//  }

//  void _addCategory() {
//    Navigator.of(context).push(
//      new MaterialPageRoute(
//        builder: (context) {
//          return new Scaffold(
//            appBar: new AppBar(
//              title: new Text('Choose Category'),
//            ),
//            body: new ListView.builder(
//                padding: const EdgeInsets.all(16.0),
//                // The itemBuilder callback is called once per suggested word pairing,
//                // and places each suggestion into a ListTile row.
//                // For even rows, the function adds a ListTile row for the word pairing.
//                // For odd rows, the function adds a Divider widget to visually
//                // separate the entries. Note that the divider may be difficult
//                // to see on smaller devices.
//                itemBuilder: (context, i) {
//                  // Add a one-pixel-high divider widget before each row in theListView.
//                  if (i.isOdd) return new Divider();
//
//                  // The syntax "i ~/ 2" divides i by 2 and returns an integer result.
//                  // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
//                  // This calculates the actual number of word pairings in the ListView,
//                  // minus the divider widgets.
//                  final index = i ~/ 2;
//                  // If you've reached the end of the available word pairings...
//                  if (index >= _suggestions.length) {
//                    // ...then generate 10 more and add them to the suggestions list.
////                    _suggestions.addAll(generateWordPairs().take(10));
//                    _suggestions.addAll(generateWordPairs().take(10));
//                  }
//                  return _buildRowOld(_suggestions[index]);
//                }
//            ),
//          );
//        },
//      ),
//    );
//  }
}
