import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/pool_model.dart';
import 'package:sunnypool_app/screens/add_piscine_screen.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';
import 'package:sunnypool_app/utils/list_piscine.dart';

class MypiscineScreen extends StatefulWidget {
  const MypiscineScreen({super.key});

  @override
  State<MypiscineScreen> createState() => _MypiscineScreen();
}

class _MypiscineScreen extends State<MypiscineScreen> {
  List<Pool> piscines = listPiscines;

  void addArticle(Pool pool) {
    setState(() {
      piscines.add(pool);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Piscines',
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
        /* actions: [
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
        ], */
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 20),
              Image.asset("assets/logo.png", height: 150),
              Text(
                "Liste de mes piscines",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: piscines.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        piscines[index].name,
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        // Naviguer vers les détails de la piscine
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DashboardScreen(pool: piscines[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Column(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddPiscineScreen(onAddPool: addArticle),
                        ),
                      );
                    },
                    child: Text(
                      'Ajouter une piscine',
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
}
