import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'camera_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'result_screen.dart';

import 'package:flutter/services.dart';

import 'package:share_plus/share_plus.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  late final Future<void> _future;
  CameraController? _cameraController;
  final textRecognizer = TextRecognizer();
  List<String> savedTexts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2D2EB),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 35),  
            Text(
              'SnapText Pro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF826D62),
              ),
            ),
            SizedBox(height: 30),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(text: 'Scanner Texte Ultime '),
                  TextSpan(
                    text: 'Précision en un Instant.',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            SizedBox(height: 10),
            Text(
              'Saved Text',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: savedTexts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildTextCard(savedTexts[index], index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                _navigateToCamera(context);
              },
              child: Icon(FontAwesomeIcons.camera),
            ),
          ),
          Positioned(
            right: 80.0,
            bottom: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                _pickImageFromGallery(context);
              },
              child: Icon(FontAwesomeIcons.fileImage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCard(String text, int index) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(
          'Texte ${index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(text),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteText(index);
              },
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                _shareText(text);
              },
            ),
          ],
        ),
        onTap: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Texte copié dans le presse-papiers'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isPermissionGranted = status == PermissionStatus.granted;
    });
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _navigateToCamera(BuildContext context) async {
    if (_isPermissionGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        savedTexts.add(recognizedText.text);
      });

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(text: recognizedText.text),
        ),
      );
    } else {
      print('User cancelled the image picking');
    }
  }

  void _deleteText(int index) {
    setState(() {
      savedTexts.removeAt(index);
    });
  }

  void _shareText(String text) {
    Share.share(text);
  }
}
