import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    Timer(
      Duration(seconds: 3),
      () {
        Navigator.of(context).pushReplacementNamed('/homescreen');
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Utilisez le format Color() pour définir les couleurs
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.camera,
                  size: 50,
                  color: Color(0xFFEEE6D8),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  color: Color(0xFFEEE6D8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
