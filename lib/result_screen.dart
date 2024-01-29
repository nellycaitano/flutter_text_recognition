import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ResultScreen extends StatelessWidget {
  final String text;

  const ResultScreen({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2A2C24),
          title: Text('Result'),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.white, // Fond blanc
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black, // Couleur du texte
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              right: 16.0,
              bottom: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () async {
                    await _saveTextToFile(text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text saved successfully'),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 16.0), // Add some spacing between buttons
            Positioned(
              right: 80.0,
              bottom: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _saveTextToFile(String text) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saved_text.txt');
    await file.writeAsString(text);
  }
}
