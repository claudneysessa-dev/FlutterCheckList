import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Camera.dart';
import 'package:flutter_app/data/html_parser.dart';
import 'package:flutter_app/model/StepClass.dart';

class StepCard extends StatefulWidget {
  const StepCard({Key key, this.step}) : super(key: key);

  final StepClass step;

  @override
  createState() => new StepCardState(this.step);
}
class StepCardState extends State<StepCard> {

  StepClass step;
  List<CameraDescription> cameras;
  TextEditingController  myController;

  StepCardState(StepClass step) {
    this.step = step;
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
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buttons(context),
            new HtmlTextView(data: step.content),
            _thumbnailWidget()
          ],
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
                  step.isDone = step.isDone ? false: true;
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
                    return new Camera(this.cameras, this.step);
                  },
                ),
              );
            },
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
            child: step.imageUrl.isEmpty
                ? new Container()
                : new Image.file(new File(step.imageUrl)),
            width: 128.0,
            height: 128.0,
            //TODO implement ontap larger image or allow user to click other image
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                content: new Hero(
                  child: new Image.file(new File(step.imageUrl)), tag: "Step Image preview",
                ),
              ),
            );
          },
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
                Navigator.of(context, rootNavigator: true).pop('dialog');
              })
        ],
      ),
    );
  }
}