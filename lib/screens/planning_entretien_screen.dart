import 'package:flutter/material.dart';
import 'profile_screen.dart';

class PlanningEntretienScreen extends StatefulWidget {
  const PlanningEntretienScreen({Key? key}) : super(key: key);

  @override
  State<PlanningEntretienScreen> createState() =>
      _PlanningEntretienScreenState();
}

const listPlanning = [
  'Néttoyer les skimmers',
  'Vérifier le niveau d\'eau',
  'Test de l\'eau et analyse',
  'Inspecter la pompe',
];

class _PlanningEntretienScreenState extends State<PlanningEntretienScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Planning d\'entretien',
          style: TextStyle(color: Colors.yellow),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
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
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: screenWidth * 0.01,
        ),
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
                    'Taches hebdomadaires recommandées pour l\'entretien de votre piscine.',
                    style: TextStyle(fontSize: screenWidth * 0.03),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: listPlanning
                    .map((item) => _buildListPlanning(item))
                    .toList(),
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 99, 99, 99),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.01,
                      ),
                    ),
                    child: Text(
                      'Ajouter une tâche',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Tâches terminées',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.01,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListPlanning(String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.all(Radius.circular(20))
        ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // pas de fond
          shadowColor: Colors.transparent, // pas d’ombre
          elevation: 0, // supprime l'élévation
          padding: EdgeInsets.zero, // supprime le padding
        ),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Icon(Icons.check_circle_outlined, color: Colors.amber, size: screenWidth * 0.05,),
          ],
        ),
      ),
    );
  }
}
