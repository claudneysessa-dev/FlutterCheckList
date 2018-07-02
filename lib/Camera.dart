import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class Camera extends StatefulWidget {
  Camera(List<CameraDescription> cameras) {
    this.cameras = cameras;
  }

  List<CameraDescription> cameras;

  @override
  _CameraAppState createState() => new _CameraAppState(this.cameras);
}

class _CameraAppState extends State<Camera> {
  CameraController controller;
  List<CameraDescription> cameras;

  _CameraAppState(List<CameraDescription> cameras) {
    this.cameras = cameras;
  }

  @override
  void initState() {
    super.initState();
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
    return new AspectRatio(
        aspectRatio:
        controller.value.aspectRatio,
        child: new CameraPreview(controller));
  }
}