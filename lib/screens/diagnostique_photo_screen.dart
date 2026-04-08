import 'package:flutter/material.dart';
import 'profile_screen.dart';

class DiagnostiquePhotoScreen extends StatefulWidget {
  const DiagnostiquePhotoScreen({super.key});

  @override
  State<DiagnostiquePhotoScreen> createState() => _DiagnostiquePhotoScreenState();
}

const listDiagnostique = [
  'Détection de la pompe',
  'Détection du skimmer',
  'Identification du robot',
  'Estimation du volume',
];

class _DiagnostiquePhotoScreenState extends State<DiagnostiquePhotoScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic photo'),
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
                    'Analyse intelligente des photos en cours.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: listDiagnostique
                    .map((item) => _buildListTutoriels(item))
                    .toList(),
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Continuer',
                  style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
                ),
              ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Passer',
                  style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
                  ),
                ],
              )
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTutoriels(String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.25)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // pas de fond
          shadowColor: Colors.transparent, // pas d’ombre
          elevation: 0, // supprime l'élévation
          padding: EdgeInsets.zero, // supprime le padding
        ),
        onPressed: () {
          
        },
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.check_circle_outline, color: Colors.amber,),
            const SizedBox(width: 10),
            Expanded(child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )),
          ],
        ),
      ),
    );
  }
}
