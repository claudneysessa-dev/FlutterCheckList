import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_app/data/database.dart';
import 'package:flutter_app/model/CheckList.dart';
import 'package:flutter_app/model/ContentClass.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Camera.dart';
import 'package:flutter_app/data/html_parser.dart';
import 'package:flutter_app/model/StepClass.dart';

class StepCard extends StatefulWidget {
  const StepCard({Key key, this.step, this.checklist}) : super(key: key);

  final StepClass step;
  final CheckList checklist;
  //TODO save checklist on step update
  @override
  createState() => new StepCardState(this.step, this.checklist);
}
class StepCardState extends State<StepCard> {
  ChecklistDatabase database;
  StepClass step;
  CheckList checklist;
  List<CameraDescription> cameras;
  TextEditingController  myController;

  @override
  void initState() {
    super.initState();
    database = ChecklistDatabase.get();
  }

  StepCardState(StepClass step, CheckList checklist) {
    this.step = step;
    this.checklist = checklist;
    this.myController = TextEditingController(text: this.step.notes);
    try {
      availableCameras()
          .then((val) => setState(() {
            cameras = val;
          })
      );
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.body1;
    List<Widget> cardChildren = new List();
    cardChildren.add(buttons(context));
    for (ContentClass content in step.contents) {
      cardChildren.add (
          new HtmlTextView(
              data: content.text.toString()
          )
      );
    }
    cardChildren.add(_thumbnailWidget());
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: cardChildren
        ),
      ),
    );
  }

  Widget buttons(BuildContext context) {
    return new Center(
      child: new ButtonBar(
        mainAxisSize: MainAxisSize.min, // this will take space as minimum as posible(to center)
        children: <Widget>[
          new IconButton(
              icon: new Icon(step.isDone ? Icons.done_all: Icons.done),
              onPressed: () {
                setState(() {
                  step.isDone = step.isDone ? false : true;
                  _updateSavedStep();
                });
              }
          ),
          new IconButton(
              icon: new Icon(
                Icons.camera
              ),
//            child: new Text('Hello'),
            onPressed: () {
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (context) {
                    return new Camera(
                        cameras: this.cameras,
                        checklist: this.checklist,
                        step: this.step
                    );
                  }
                ),
              );
            }
          ),
          new IconButton(
            icon: new Icon(Icons.note_add),
            onPressed: _showDialog
          ),
        ],
      ),
    );
  }

  Widget _thumbnailWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.bottomCenter,
        child: new GestureDetector(
          child: new SizedBox(
            child: step.imagePath.isEmpty
                ? new Container()
                : new Image.file(new File(step.imagePath)),
            width: 128.0,
            height: 128.0,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                content: new Hero(
                  child: new Image.file(new File(step.imagePath)), tag: "Step Image preview",
                ),
                actions: <Widget>[
                  new FlatButton(
                      child: const Text('REMOVE'),
                      onPressed: () {
                        setState(() {
                          step.imagePath = "";
                          _updateSavedStep();
                        });
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                      }),
                  //TODO implement button to pick image from gallery
                ],
              ),
            );
          }
        )
      ),
    );
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      builder: (_) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                controller: myController,
                decoration: new InputDecoration(
                    labelText: 'Add Notes', hintText: 'eg. This step required extra efforts.'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              }),
          new FlatButton(
              child: const Text('ADD'),
              onPressed: () {
                step.notes = myController.text;
                _updateSavedStep();
                Navigator.of(context, rootNavigator: true).pop('dialog');
              })
        ],
      ),
    );
  }

  _updateSavedStep() {
    database.upsertSavedStep(checklist: checklist, step: step);
  }
}