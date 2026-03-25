import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunnypool_app/screens/analyse_screen.dart';
import 'package:sunnypool_app/screens/photos_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> pools = [];

  List<String> maintenanceChecked = [];

  List<String> maintenance = [
    "Vérifier le pH",
    "Nettoyer skimmer",
    "entretien 3",
    "entretien 4",
    "entretien 5",
  ];

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
              Text(
                "Sunny",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    height: 150,
                    decoration: BoxDecoration(
                      // color: const Color.fromARGB(255, 70, 73, 74),
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage("assets/piscine.png"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.1),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ma piscine",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "32 m³",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 32,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Traitement: chlore",
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: 0.7,
                                  backgroundColor: Colors.white24,
                                  color: Colors.amber,
                                  minHeight: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 70, 73, 74),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.amber),
                        SizedBox(width: 10),
                        Text(
                          "29°C",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Ensoleillé",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "°",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Vent faible",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 153, 153, 153),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildContainerRow(
                    Icons.science,
                    "Analyse de l'eau",
                    AnalyseScreen(),
                  ),
                  _buildContainerRow(
                    Icons.photo,
                    "Photo piscine",
                    PhotosScreen(),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildContainerRow(Icons.message, "Parler à Sunny",),
                  _buildContainerRow(Icons.add, "Ajouter produit",),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 70, 73, 74),
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 350,
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prochain entretien',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(color: Colors.white54, height: 20),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: maintenance
                            .map(
                              (item) => CheckboxListTile(
                                title: Text(
                                  item,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                value: maintenanceChecked.contains(item),
                                checkColor: Colors.black,
                                activeColor: const Color.fromARGB(
                                  255,
                                  137,
                                  255,
                                  139,
                                ),
                                hoverColor: const Color.fromARGB(
                                  255,
                                  137,
                                  255,
                                  139,
                                ).withOpacity(0.2),
                                onChanged: (bool? value) {
                                  setState(() {
                                    maintenanceChecked.contains(item)
                                        ? maintenanceChecked.remove(item)
                                        : maintenanceChecked.add(item);
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              /* pools.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Aucune piscine disponible",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        onPressed: _addPool,
                        child: Text("Ajouter une piscine"),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: pools.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey[900],
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Icon(Icons.pool, color: Colors.amber),
                          title: Text(
                            pools[index],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ), */
            ],
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Ouverture: $title")));
      },
    );
  }

  Widget _buildContainerRow(
    IconData icon,
    String title,
     [
    Widget? destination,
  ]) {
    return Expanded(
      child: Container(
        // padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 70, 73, 74),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            alignment: Alignment.centerLeft,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    destination ??
                    Scaffold(
                      appBar: AppBar(title: Text(title)),
                      body: Center(child: Text("Page $title en construction")),
                    ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.amber, size: 40),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
