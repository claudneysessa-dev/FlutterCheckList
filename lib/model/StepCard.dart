import 'dart:async';

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

  StepCardState(StepClass step) {
    this.step = step;
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
//            Text(step.content, style: textStyle, overflow: TextOverflow.clip,),
//            Icon(Icons.check_box, size: 128.0, color: textStyle.color),
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
              icon: new Icon(Icons.done),
              onPressed: null
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
                    return new Scaffold(
                        appBar: new AppBar(
                          title: new Text('Camera'),
                        ),
                        body: new Camera(cameras)
                    );
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
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('OPEN'),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),
    );
  }
}