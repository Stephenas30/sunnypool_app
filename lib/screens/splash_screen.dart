import 'package:flutter/material.dart';
import '../utils/token_storage.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
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
            Text("SunnyPool", style: TextStyle(color: Colors.yellow, fontSize: 24)),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.yellow),
          ],
        ),
      ),
    );
  }
}