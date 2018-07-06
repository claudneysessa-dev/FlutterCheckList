import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_app/data/database.dart';
import 'package:flutter_app/model/CheckList.dart';
import 'package:flutter_app/model/StepClass.dart';
import 'package:path_provider/path_provider.dart';

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class Camera extends StatefulWidget {
  List<CameraDescription> cameras;
  StepClass step;
  CheckList checklist;
  String imagePath;

  Camera({this.cameras, this.checklist, this.step});

  @override
  _CameraAppState createState() => new _CameraAppState(
      cameras: this.cameras,
      checklist: this.checklist,
      step: this.step
  );
}

class _CameraAppState extends State<Camera> {
  ChecklistDatabase database;
  CameraController controller;
  List<CameraDescription> cameras;
  StepClass step;
  CheckList checklist;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  _CameraAppState({this.cameras, this.checklist, this.step});

  @override
  void initState() {
    super.initState();
    database = ChecklistDatabase.get();
    controller = new CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return new Container();
    }
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Camera'),
      ),
      body: new AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: new CameraPreview(controller)
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: onTakePictureButtonPressed,
        child: const Icon(
          Icons.camera,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          step.imagePath = filePath;
          database.upsertSavedStep(checklist: checklist, step: step);
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
        Navigator.of(context).pop();
      }
    });
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}