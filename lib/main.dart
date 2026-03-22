import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(SunnyPoolApp());
}

class SunnyPoolApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SunnyPool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: SplashScreen(),
    );
  }
}