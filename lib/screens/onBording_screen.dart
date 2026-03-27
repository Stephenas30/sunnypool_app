import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/login_screen.dart';
import 'package:sunnypool_app/screens/register_screen.dart';

class OnbordingScreen extends StatelessWidget {
  const OnbordingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsetsGeometry.all(30),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Image.asset('assets/icon.png', height: screenHeight / 4),
                Text(
                  'Bienvenue sur Sunny',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  width: screenWidth,
                  child: Text(
                    'L\'assistant intelligent qui comprend votre piscine et vous guide au quotidien.',
                    style: TextStyle(fontSize: screenWidth * 0.03),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Text(
                  '☀️​ Analyse de l\'eau',
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
                Text(
                  '​🧪​ Dosages précis',
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
                Text(
                  '​🤖​ Assistance de IA 24/7',
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
              ],
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: Text(
                    'Se connecter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
            // ),
          ],
        ),
      ),
      // ),
    );
  }
}
