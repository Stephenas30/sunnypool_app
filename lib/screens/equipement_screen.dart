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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Équipements'),
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
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: screenWidth * 0.08),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: screenHeight / 7),
                    const SizedBox(height: 10),
                    Text(
                      'Ajoutons les équipements présents dans votre piscine.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: listEquipement.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _buildListEquipement(listEquipement[index]),
                ),
              ),
              const SizedBox(height: 12),
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
          ),
        ),
      ),
    );
  }

  Widget _buildListEquipement(String title) {
    final selected = equipementChecked == title;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () {
          setState(() {
            equipementChecked = title;
          });
        },
        leading: Icon(
          selected ? Icons.check_circle : Icons.handyman_outlined,
          color: selected ? Colors.amber : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.amber : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: selected ? Colors.amber : Colors.white54,
        ),
      ),
    );
  }
}
