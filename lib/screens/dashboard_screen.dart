import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> pools = [];

  void _addPool() {
    setState(() {
      pools.add("Nouvelle piscine #${pools.length + 1}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.black, // couleur de la barre de notif
        statusBarIconBrightness: Brightness.light, // icônes visibles
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/logo.png", height: 32),
              SizedBox(width: 8),
              Text("Sunny",
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          iconTheme: IconThemeData(color: Colors.amber),
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
        drawer: Drawer(
          backgroundColor: Colors.black,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: 40),
              Image.asset("assets/logo.png", height: 150),
              _buildMenuItem(Icons.science, "Analyse de l'eau"),
              _buildMenuItem(Icons.camera_alt, "Diagnostic photo"),
              _buildMenuItem(Icons.history, "Historique des analyses"),
              _buildMenuItem(Icons.chat, "Parler à Sunny"),
              _buildMenuItem(Icons.inventory, "Mes produits"),
              _buildMenuItem(Icons.calendar_today, "Planning d'entretien"),
              _buildMenuItem(Icons.school, "Tutoriels"),
            ],
          ),
        ),
        body: Center(
          child: pools.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Aucune piscine disponible",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15)),
                      onPressed: _addPool,
                      child: Text("Ajouter une piscine"),
                    )
                  ],
                )
              : ListView.builder(
                  itemCount: pools.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.grey[900],
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.pool, color: Colors.amber),
                        title: Text(
                          pools[index],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ouverture: $title")),
        );
      },
    );
  }
}