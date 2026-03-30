import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';
import 'package:sunnypool_app/screens/onBording_screen.dart';
import 'package:sunnypool_app/screens/planning_entretien_screen.dart';
import '../utils/token_storage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      _checkAuth();
    });
  }

  void _checkAuth() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnbordingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png", height: 200),
            SizedBox(height: 20),
            Text("Assistant piscine intelligent", style: TextStyle(color: Colors.yellow, fontSize: 24)),
            // SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.yellow),
          ],
        ),
      ),
    );
  }
}