import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/login_screen.dart';
import 'package:sunnypool_app/screens/register_screen.dart';

class OnbordingScreen extends StatelessWidget {
  const OnbordingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon.png', height: 320),
            Text(
              'Bienvenue sur Sunny',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Center(
              child:
                  (
                  // SizedBox(width: 20,),
                  Container(
                    padding: EdgeInsets.all(16),
                    width: 290,
                    child: Text(
                      'L\'assistant intelligent qui comprend votre piscine et vous guide au quotidien.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  )
                  // SizedBox(width: 10,),
                  ),
            ),
            Text('☀️​ Analyse de l\'eau'),
            Text('​🧪​ Dosages précis'),
            Text('​🤖​ Assistance de IA 24/7'),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              child: Text(
                'Créer un compte',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
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
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
