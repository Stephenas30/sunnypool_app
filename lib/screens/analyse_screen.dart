import 'package:flutter/material.dart';
import 'profile_screen.dart';

class AnalyseScreen extends StatefulWidget {
  const AnalyseScreen({Key? key}) : super(key: key);

  @override
  State<AnalyseScreen> createState() => _AnalyseScreenState();
}

const listAnalyse = ['pH', 'Chlore', 'TAC', 'Stabilisant', 'Température'];
String analyseChecked = 'pH';


class _AnalyseScreenState extends State<AnalyseScreen> {
  late List<bool> buttonSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse de l\'eau'),
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
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.25)),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModeButton(
                        label: 'Saisir les valeurs',
                        selected: buttonSelected[0],
                        onPressed: () {
                          setState(() {
                            buttonSelected[0] = true;
                            buttonSelected[1] = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildModeButton(
                        label: 'Photo bandelette',
                        selected: buttonSelected[1],
                        onPressed: () {
                          setState(() {
                            buttonSelected[0] = false;
                            buttonSelected[1] = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: listAnalyse.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _buildListAnalyse(listAnalyse[index]),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Analyser',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: selected ? Colors.amber : Colors.transparent,
        foregroundColor: selected ? Colors.black : Colors.amber,
        side: BorderSide(color: selected ? Colors.amber : Colors.amber.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      child: Text(label, textAlign: TextAlign.center),
    );
  }

  Widget _buildListAnalyse(String title) {
    final selected = analyseChecked == title;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () {
          setState(() {
            analyseChecked = title;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Icon(
          selected ? Icons.check_circle : Icons.water_drop_outlined,
          color: selected ? Colors.amber : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.amber : Colors.white,
            fontWeight: FontWeight.w700,
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
