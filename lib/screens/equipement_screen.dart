import 'package:flutter/material.dart';
import 'profile_screen.dart';

class EquipementScreen extends StatefulWidget {
  const EquipementScreen({Key? key}) : super(key: key);

  @override
  State<EquipementScreen> createState() => _EquipementScreenState();
}

const listEquipement = [
  'Robot nettoyeurs',
  'Pompe',
  'Chlorinateur au sel',
  'Pompe à chaleur',
];
String equipementChecked = '';

class _EquipementScreenState extends State<EquipementScreen> {
  late List<bool> buttonSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Équipements',
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
          horizontal: screenWidth * 0.08,
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
                    'Ajoutons les équipements présents dans votre piscine.',
                    style: TextStyle(fontSize: screenWidth * 0.03),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),

                children: listEquipement
                    .map((item) => _buildListEquipement(item))
                    .toList(),
              ),
              Column(
                spacing: 12,
                children: [
                  ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Continuer',
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
                  'Passer',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.white,
                  ),
                ),
              ),
                ],
              )
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListEquipement(String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            equipementChecked.compareTo(title) == 0
                ? Colors.amber
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
        onPressed: () {
          setState(() {
            if (equipementChecked.compareTo(title) == 0) {
              equipementChecked = title;
            } else {
              equipementChecked = title;
            }
          });
        },
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
