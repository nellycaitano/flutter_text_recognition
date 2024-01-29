import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'splash_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
    
      home: SplashScreen(),
    routes: {
    '/homescreen': (context) => MainScreen()
  },
);
    
  }
}