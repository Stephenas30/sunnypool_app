import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';
import 'package:sunnypool_app/screens/onBording_screen.dart';
import '../utils/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
      if(context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
      }
    } else {
      if(context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnbordingScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png", height: 200),
            SizedBox(height: 5),
            Text("Assistant piscine intelligent", style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03)),
            SizedBox(height: 50),
            CircularProgressIndicator(color: Colors.yellow),
          ],
        ),
      ),
    );
  }
}