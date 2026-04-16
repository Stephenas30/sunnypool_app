import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/login_screen.dart';
import 'package:sunnypool_app/screens/register_screen.dart';

class OnbordingScreen extends StatelessWidget {
  const OnbordingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050505), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image.asset('assets/icon.png', height: screenHeight / 4.6),
                    const SizedBox(height: 12),
                    Text(
                      'Bienvenue sur Sunny',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.08,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'L\'assistant intelligent qui comprend votre piscine et vous guide au quotidien.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: screenWidth * 0.035,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('☀️ Analyse de l\'eau', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('🧪 Dosages précis', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('🤖 Assistance IA 24/7', style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Créer un compte',
                          style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.amber),
                          foregroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Se connecter',
                          style: theme.textTheme.labelLarge?.copyWith(color: Colors.amber),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
