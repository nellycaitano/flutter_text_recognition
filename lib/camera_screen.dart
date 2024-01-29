  import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'result_screen.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late TextRecognizer _textRecognizer;

  @override
void initState() {
  super.initState();
  _initializeCamera().then((_) {
    _textRecognizer = TextRecognizer();
    if (!mounted) {
      return;
    }
    setState(() {});
  });
}

 Future<void> _initializeCamera() async {
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  _cameraController = CameraController(
    firstCamera,
    ResolutionPreset.max,
    enableAudio: false,
  );

  await _cameraController!.initialize();
}



  @override
  void dispose() {
    _cameraController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Preview'),
      ),
      body: CameraPreview(_cameraController),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanImage,
        child: Icon(Icons.camera),
      ),
    );
  }

  Future<void> _scanImage() async {
    final navigator = Navigator.of(context);

    try {
      final pictureFile = await _cameraController.takePicture();

      final file = File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);

      final recognizedText = await _textRecognizer.processImage(inputImage);

      await navigator.push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(text: recognizedText.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }
}
