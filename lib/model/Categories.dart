import 'package:flutter_app/data/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/EditCheckList.dart';
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
  ChecklistDatabase database;
  final _saved = new Set<CheckList>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    database = ChecklistDatabase.get();
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
    return FutureBuilder<List<CheckList>>(
      future: database.getSavedChecklists(),
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
      }
    );
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
        }
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
        }
      ),
    );
  }

  Widget _buildCategories() {
    return FutureBuilder<List<CategoryClass>>(
      future: database.getCategories(),
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
      }
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
          checkList.category.name
        ),
        trailing: new Text(
          checkList.humanReadableTime(checkList.timestamp)
        ),
        onTap: () {
          setState(() {
            if (!checkList.alreadySaved) {
              //save to _saved list
              checkList.alreadySaved = true;
              database.saveCheckList(checkList);
              _saved.add(checkList);
              Navigator.pop(context);
            } else {
              //open for edit
              _editCheckList(checkList);
            }
          });
        }
      );
    }
  }
}
