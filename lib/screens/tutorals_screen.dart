import 'package:flutter/material.dart';
import 'profile_screen.dart';

class TutoralsScreen extends StatefulWidget {
  const TutoralsScreen({super.key});

  @override
  State<TutoralsScreen> createState() => _TutoralsScreenState();
}

const listTutoriels = [
  'Nettoyer votre piscine',
  'Entretenir votre robot nettoyeur',
  'Utiliser le chlore et le pH+',
  'Maintenance de la pompe',
  'Couvrir votre piscine',
];
String tutorielsChecked = '';

class _TutoralsScreenState extends State<TutoralsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutoriels'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage("assets/icon.png"),
              radius: 16,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050505), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: screenWidth * 0.04),
          child: Center(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 20,
            children: [
              Column(
                children: [
                  Image.asset('assets/logo.png', height: screenHeight / 6),
                  Text(
                    'Guide et conseils pour l\'entretien de votre piscine.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: listTutoriels
                    .map((item) => _buildListTutoriels(item))
                    .toList(),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTutoriels(String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final selected = tutorielsChecked == title;
    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? Colors.amber : Colors.white24),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // pas de fond
          shadowColor: Colors.transparent, // pas d’ombre
          elevation: 0, // supprime l'élévation
          padding: EdgeInsets.zero, // supprime le padding
        ),
        onPressed: () {
          setState(() {
            tutorielsChecked = title;
          });
        },
        child: Row(
          children: [
            Expanded(
              child: Image.asset(
                'assets/piscine.png',
                height: screenHeight * 0.08,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.amber : Colors.white,
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Icon(
                Icons.play_circle_outline_outlined,
                color: selected ? Colors.amber : Colors.white70,
                size: screenWidth * 0.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
