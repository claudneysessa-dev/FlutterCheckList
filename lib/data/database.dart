import 'dart:async';
import 'dart:io';
import 'package:flutter_app/data/category_parser.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/model/CategoryClass.dart';
import 'package:flutter_app/model/CheckList.dart';
import 'package:flutter_app/model/StepClass.dart';
import 'package:flutter_app/model/ContentClass.dart';

class ChecklistDatabase {
  static final ChecklistDatabase _checklistDatabase = new ChecklistDatabase._internal();

  final String categoryTableName = "Categories";
  final String checklistTableName = "Checklists";
  final String stepTableName = "Steps";
  final String contentTableName = "Contents";
  final String savedChecklistTableName = "SavedChecklists";
  final String savedStepTableName = "SavedSteps";

  Database db;

  bool didInit = false;

  static ChecklistDatabase get() {
    return _checklistDatabase;
  }

  ChecklistDatabase._internal();

  /// Use this method to access the database, because initialization of the database (it has to go through the method channel)
  Future<Database> _getDb() async{
    if(!didInit) await _init();
    return db;
  }

  Future init() async {
    return await _init();
  }

  Future _init() async {
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "checklist.db");
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
            "CREATE TABLE $categoryTableName ("
                "${CategoryClass.db_id} INTEGER PRIMARY KEY,"
                "${CategoryClass.db_name} TEXT NOT NULL,"
                "${CategoryClass.db_type} TEXT NOT NULL"
                ")"
          );

          await db.execute(
            "CREATE TABLE $checklistTableName ("
                "${CheckList.db_id} INTEGER PRIMARY KEY,"
                "${CheckList.db_name} TEXT NOT NULL,"
                "${CheckList.db_type} TEXT NOT NULL,"
                "${CheckList.db_category_id} INTEGER NOT NULL,"
                "FOREIGN KEY (${CheckList.db_category_id}) REFERENCES $categoryTableName (${CategoryClass.db_id})"
                "ON DELETE CASCADE ON UPDATE NO ACTION"
                ")"
          );

          await db.execute(
            "CREATE TABLE $stepTableName ("
                "${StepClass.db_id} INTEGER PRIMARY KEY,"
                "${StepClass.db_name} TEXT NOT NULL,"
                "${StepClass.db_type} TEXT NOT NULL,"
                "${StepClass.db_checklist_id} INTEGER NOT NULL,"
                "FOREIGN KEY (${StepClass.db_checklist_id}) REFERENCES $checklistTableName (${CheckList.db_id})"
                "ON DELETE CASCADE ON UPDATE NO ACTION"
                ")"
          );

          await db.execute(
            "CREATE TABLE $contentTableName ("
                "${ContentClass.db_id} INTEGER PRIMARY KEY,"
                "${ContentClass.db_name} TEXT NOT NULL,"
                "${ContentClass.db_type} TEXT NOT NULL,"
                "${ContentClass.db_text} TEXT NOT NULL,"
                "${ContentClass.db_step_id} INTEGER NOT NULL,"
                "FOREIGN KEY (${ContentClass.db_step_id}) REFERENCES $stepTableName (${StepClass.db_id})"
                "ON DELETE CASCADE ON UPDATE NO ACTION"
                ")"
          );

          await db.execute(
            "CREATE TABLE $savedChecklistTableName ("
              "${CheckList.db_id} INTEGER PRIMARY KEY,"
              "${StepClass.db_checklist_id} INTEGER NOT NULL,"
              "date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
              "FOREIGN KEY (${StepClass.db_checklist_id}) REFERENCES $checklistTableName (${CheckList.db_id})"
              "ON DELETE CASCADE ON UPDATE NO ACTION"
              ")"
          );

          await db.execute(
              "CREATE TABLE $savedStepTableName ("
                  "${StepClass.db_id} INTEGER NOT NULL PRIMARY KEY,"
                  "${StepClass.db_saved_checklist_id} INTEGER NOT NULL,"
                  "${StepClass.db_saved_step_id} INTEGER NOT NULL,"
                  "${StepClass.db_notes} TEXT NULL,"
                  "${StepClass.db_imagePath} TEXT NULL,"
                  "${StepClass.db_isDone} BIT NOT NULL DEFAULT 0,"
                  "date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
                  "FOREIGN KEY (${StepClass.db_saved_checklist_id}) REFERENCES $savedChecklistTableName (${CheckList.db_id})"
                  "ON DELETE CASCADE ON UPDATE NO ACTION"
                  ")");

          await populateDatabase();
        });
    didInit = true;
  }

  populateDatabase() async {
    List<CategoryClass> categories = await fetchCategories();
    categories.forEach((category) async {
      await upsertCategory(category).then((cat) {
        cat.checkLists.forEach((checklist) async {
          await upsertCheckList(checklist).then((check) {
            check.steps.forEach((step) async {
              await upsertStep(step).then((s) {
                s.contents.forEach((content) async {
                  await upsertContent(content);
                });
              });
            });
          });
        });
      });
    });
  }

  Future<CategoryClass> getCategory(String id) async{
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $categoryTableName WHERE ${CategoryClass.db_id} = "$id"');
    if(result.length == 0)return null;
    return new CategoryClass.fromMap(result[0]);
  }

  Future<List<CategoryClass>> getCategories({List<String> ids}) async{
    var db = await _getDb();
    List<CategoryClass> categories = [];
    if (ids != null) {
      // Building SELECT * FROM TABLE WHERE ID IN (id1, id2, ..., idn)
      var idsString = ids.map((it) => '"$it"').join(',');
      var result = await db.rawQuery(
          'SELECT * FROM $categoryTableName WHERE ${CategoryClass
              .db_id} IN ($idsString)');

      for (Map<String, dynamic> item in result) {
        categories.add(new CategoryClass.fromMap(item));
      }
    } else {
      List<Map> results = await db.query(
          categoryTableName,
          columns: CategoryClass.columns,
          limit: 20,
          orderBy: "id DESC"
      );
      if (results.length == 0 ) return [];
      for(var result in results) {
        CategoryClass category = CategoryClass.fromMap(result);
        category.checkLists = await getChecklists(category: category);
        categories.add(category);
      }
    }
    return categories;
  }

  Future<CheckList> getChecklist(String id) async{
    var db = await _getDb();
    List<Map> results = await db.query(
        checklistTableName,
        columns: CheckList.columns,
        limit: 1,
        where: "${CheckList.db_id} = ?",
        whereArgs: [id]
    );
    if(results.length == 0) return null;
    return new CheckList.fromMap(results[0]);
  }

  Future<List<CheckList>> getChecklists({List<String> ids, CategoryClass category}) async{
    var db = await _getDb();
    List<CheckList> checklists = [];
    if (category != null) {
      List<Map> results = await db.query(
          checklistTableName,
          columns: CheckList.columns,
          limit: 20,
          where: "${CheckList.db_category_id} = ?",
          whereArgs: [category.id.toString()]
      );
      if(results.length == 0) return [];
      for (var result in results) {
        CheckList checklist = CheckList.fromMap(result);
        checklist.category = category;
        checklist.steps = await getSteps(checklist: checklist);
        checklists.add(checklist);
      }
    } else {
      // Building SELECT * FROM TABLE WHERE ID IN (id1, id2, ..., idn)
      var idsString = ids.map((it) => '"$it"').join(',');
      var result = await db.rawQuery(
          'SELECT * FROM $checklistTableName WHERE ${CheckList
              .db_id} IN ($idsString)');

      for (Map<String, dynamic> item in result) {
        checklists.add(new CheckList.fromMap(item));
      }
    }
    return checklists;
  }

  Future<List<Map<String, dynamic>>> getSavedStepsData(String id) async {
    var db = await _getDb();
    // Building SELECT * FROM TABLE WHERE ID IN (id1, id2, ..., idn)
    var result = await db.rawQuery('SELECT * FROM $savedStepTableName WHERE ${StepClass.db_saved_checklist_id} = $id order by ${StepClass.db_saved_step_id}');
    if (result.length == 0) return [];
    return result;
  }

  Future<List<CheckList>> getSavedChecklists() async{
    var db = await _getDb();
    var results = await db.rawQuery('SELECT * FROM $savedChecklistTableName ORDER BY date_time DESC');
    if(results.length == 0)return [];
    List<CheckList> checklists = [];
    for(Map<String,dynamic> map in results) {
      var savedChecklistId = map[CheckList.db_id];
      var checklistId = map[StepClass.db_checklist_id];
      CheckList checklist = await getChecklist(checklistId.toString());
      checklist.alreadySaved = true;
      checklist.category = await getCategory(checklist.category_id.toString());
      checklist.steps = await getSteps(checklist: checklist);
      var stepsData = await getSavedStepsData(savedChecklistId.toString());
      for (Map<String,dynamic> stepData in stepsData) {
        for (StepClass step in checklist.steps) {
          if (step.id == stepData["id"]) {
            step.isDone = stepData[StepClass.db_isDone];
            step.notes = stepData[StepClass.db_notes];
            step.imagePath = stepData[StepClass.db_imagePath];
          }
        }
      }
      checklists.add(checklist);
    }
    return checklists;
  }

  Future<StepClass> getStep(String id) async{
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $stepTableName WHERE ${StepClass.db_id} = "$id"');
    if(result.length == 0)return null;
    return new StepClass.fromMap(result[0]);
  }

  Future<List<StepClass>> getSteps({List<String> ids, CheckList checklist}) async{
    var db = await _getDb();
    List<StepClass> steps = [];
    if (checklist != null) {
      List<Map> results = await db.query(
          stepTableName,
          columns: StepClass.columns,
          where: "${StepClass.db_checklist_id} = ?",
          whereArgs: [checklist.id.toString()]
      );
      if(results.length == 0) return [];
      for(var result in results) {
        StepClass stepClass = StepClass.fromMap(result);
        stepClass.checklist = checklist;
        stepClass.isDone = false;
        stepClass.notes = "";
        stepClass.imagePath = "";
        stepClass.contents = await getContents(step: stepClass.id.toString());
        steps.add(stepClass);
      }
    } else {
      // Building SELECT * FROM TABLE WHERE ID IN (id1, id2, ..., idn)
      var idsString = ids.map((it) => '"$it"').join(',');
      var result = await db.rawQuery(
          'SELECT * FROM $stepTableName WHERE ${StepClass
              .db_id} IN ($idsString)');

      for (Map<String, dynamic> item in result) {
        steps.add(new StepClass.fromMap(item));
      }
    }
    return steps;
  }

  Future<ContentClass> getContent(String id) async{
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $contentTableName WHERE ${ContentClass.db_id} = "$id"');
    if(result.length == 0)return null;
    return new ContentClass.fromMap(result[0]);
  }

  Future<List<ContentClass>> getContents({List<String> ids, String step}) async{
    var db = await _getDb();
    List<ContentClass> contents = [];
    if (step != null) {
      List<Map> results = await db.query(
          contentTableName,
          columns: ContentClass.columns,
          where: "${ContentClass.db_step_id} = ?",
          whereArgs: [step]
      );
      if(results.length == 0) return [];
      for(var result in results) {
        ContentClass contentClass = ContentClass.fromMap(result);
        contents.add(contentClass);
      }
    } else {
      // Building SELECT * FROM TABLE WHERE ID IN (id1, id2, ..., idn)
      var idsString = ids.map((it) => '"$it"').join(',');
      var result = await db.rawQuery(
          'SELECT * FROM $contentTableName WHERE ${ContentClass
              .db_id} IN ($idsString)');

      for (Map<String, dynamic> item in result) {
        contents.add(new ContentClass.fromMap(item));
      }
    }
    return contents;
  }


  //TODO escape not allowed characters eg. ' " '
  /// Inserts or replaces the book.
//  Future updateBook(Book book) async {
//    var db = await _getDb();
//    await db.rawInsert(
//        'INSERT OR REPLACE INTO '
//            '$tableName(${Book.db_id}, ${Book.db_title}, ${Book.db_url}, ${Book.db_star}, ${Book.db_notes}, ${Book.db_author}, ${Book.db_description}, ${Book.db_subtitle})'
//            ' VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
//        [book.id, book.title, book.url, book.starred? 1:0, book.notes, book.author, book.description, book.subtitle]);
//
//  }

  Future<CategoryClass> upsertCategory(CategoryClass category) async {
    var db = await _getDb();
    var count = Sqflite.firstIntValue(
        await db.rawQuery(
            "SELECT COUNT(*) FROM $categoryTableName WHERE name = ?",
            [category.name]
        )
    );
    if (count == 0) {
      category.id = await db.insert(categoryTableName, category.toMap());
    } else {
      await db.update(categoryTableName, category.toMap(), where: "id = ?", whereArgs: [category.id]);
    }
    print("Upserted ${category.id} with name ${category.name}");
    return category;
  }

  Future<CheckList> upsertCheckList(CheckList checklist) async {
    var db = await _getDb();
    var count = Sqflite.firstIntValue(
        await db.rawQuery(
            "SELECT COUNT(*) FROM $checklistTableName WHERE name = ?",
            [checklist.name]
        )
    );
    if (count == 0) {
      checklist.id = await db.insert(checklistTableName, checklist.toMap());
    } else {
      await db.update(
          checklistTableName,
          checklist.toMap(),
          where: "id = ?",
          whereArgs: [checklist.id]
      );
    }
    print("Upserted ${checklist.id} with name ${checklist.name}");

    return checklist;
  }

  Future saveCheckList(CheckList checklist) async {
    var db = await _getDb();
    await db.rawInsert(
        'INSERT OR REPLACE INTO '
            '$savedChecklistTableName(${StepClass.db_checklist_id})'
            ' VALUES(?)',
        [checklist.id]);
  }

  Future<StepClass> upsertStep(StepClass step) async {
    var db = await _getDb();
    var count = Sqflite.firstIntValue(
        await db.rawQuery(
            "SELECT COUNT(*) FROM $stepTableName WHERE name = ?",
            [step.name]
        )
    );
    if (count == 0) {
      step.id = await db.insert(stepTableName, step.toMap());
    } else {
      await db.update(
          stepTableName,
          step.toMap(),
          where: "id = ?",
          whereArgs: [step.id]
      );
    }
    print("Upserted ${step.id} with name ${step.name}");

    return step;
  }

  Future<ContentClass> upsertContent(ContentClass content) async {
    var db = await _getDb();
    var count = Sqflite.firstIntValue(
        await db.rawQuery(
            "SELECT COUNT(*) FROM $contentTableName WHERE name = ?",
            [content.name]
        )
    );
    if (count == 0) {
      content.id = await db.insert(contentTableName, content.toMap());
    } else {
      await db.update(
          contentTableName,
          content.toMap(),
          where: "id = ?",
          whereArgs: [content.id]
      );
    }
    print("Upserted ${content.id} with name ${content.name}");

    return content;
  }

  Future close() async {
    var db = await _getDb();
    return db.close();
  }

}