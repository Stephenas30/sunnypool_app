import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunnypool_app/models/pool_model.dart';
import 'package:sunnypool_app/screens/analyse_screen.dart';
import 'package:sunnypool_app/screens/configurationPiscine_screen.dart';
import 'package:sunnypool_app/screens/historique_analyses.dart';
import 'package:sunnypool_app/screens/mypiscine_screen.dart';
import 'package:sunnypool_app/screens/photos_screen.dart';
import 'package:sunnypool_app/screens/planning_entretien_screen.dart';
import 'package:sunnypool_app/screens/product_sreen.dart';
import 'package:sunnypool_app/screens/tutorals_screen.dart';
import 'package:sunnypool_app/services/meteo_service.dart';
import 'package:sunnypool_app/utils/list_piscine.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Pool? pool;
  DashboardScreen({Key? key, this.pool}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> weatherFuture;
  Pool? checkPool;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    checkPool = widget.pool ?? listPiscines.first;
    weatherFuture = getWeather(
      checkPool!.location.latitude,
      checkPool!.location.longitude,
    );

    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        weatherFuture = getWeather(
          checkPool!.location.latitude,
          checkPool!.location.longitude,
        );
      });
    });
  }

  /* Pool pool = Pool(
    id: '1',
    name: 'Ma Piscine',
    type: TypePool.coque,
    dimension: Dimension(length: 8, width: 4, depth: 1.5),
    description: 'Piscine familiale dans le jardin',
  ); */

  List<String> pools = [];
  List<String> maintenanceChecked = [];
  List<String> maintenance = [
    "Vérifier le pH",
    "Nettoyer skimmer",
    "entretien 3",
    "entretien 4",
    "entretien 5",
  ];

  Map<String, dynamic> traitement = {'product': 'Chlore', 'percent': 0.7};
  double temperature = 29;
  List temps = ['Ensoleillé', 'Vent faible'];

  void _addPool() {
    setState(() {
      pools.add("Nouvelle piscine #${pools.length + 1}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
              _buildMenuItem(Icons.pool, "Mes piscines", MypiscineScreen()),
              _buildMenuItem(
                Icons.science,
                "Analyse de l'eau",
                AnalyseScreen(),
              ),
              _buildMenuItem(
                Icons.camera_alt,
                "Diagnostic photo",
                PhotosScreen(),
              ),
              _buildMenuItem(
                Icons.history,
                "Historique des analyses",
                HistoriqueAnalyses(),
              ),
              _buildMenuItem(Icons.chat, "Parler à Sunny"),
              _buildMenuItem(Icons.inventory, "Mes produits", ProductScreen()),
              _buildMenuItem(
                Icons.calendar_today,
                "Planning d'entretien",
                PlanningEntretienScreen(),
              ),
              _buildMenuItem(Icons.school, "Tutoriels", TutoralsScreen()),
            ],
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16,
              children: [
                Container(
                  width: double.infinity,
                  //margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  // height: 150,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
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
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(
                              title: const Text(
                                'Votre Piscine',
                                style: TextStyle(color: Colors.yellow),
                              ),
                              backgroundColor: Colors.black,
                              leading: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.yellow,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              centerTitle: true,
                              actions: [
                                IconButton(
                                  icon: CircleAvatar(
                                    backgroundImage: AssetImage(
                                      "assets/icon.png",
                                    ),
                                    radius: 16,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProfileScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            body: ConfigurationpiscineScreen(
                              pool: checkPool,
                              traitementChecked: [traitement['product']],
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              checkPool?.name ?? "Nom de la piscine",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: screenWidth * 0.08,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${checkPool?.volume} m³",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: screenWidth * 0.07,
                                // fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        /* Container(
                        child: */
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Traitement: ${traitement['product']}",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            LinearProgressIndicator(
                              value: traitement['percent'],
                              backgroundColor: Colors.white24,
                              color: Colors.amber,
                              minHeight: 8,
                            ),
                          ],
                        ),
                        // ),
                      ],
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 70, 73, 74),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(16),
                  // margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Colors.amber,
                            size: screenHeight * 0.05,
                          ),
                          FutureBuilder(
                            future: weatherFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return CircularProgressIndicator();

                              final weather = snapshot.data!['current_weather'];

                              return Text(
                                '${weather['temperature']}°C',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.07,
                                  // fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Text(
                            temps[0],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                          Text(
                            ".",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                          Text(
                            temps[1],
                            style: TextStyle(
                              color: const Color.fromARGB(255, 153, 153, 153),
                              fontSize: screenWidth * 0.03,
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
                  spacing: 16,
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
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildContainerRow(Icons.message, "Parler à Sunny"),
                    _buildContainerRow(
                      Icons.add,
                      "Ajouter produit",
                      ProductScreen(),
                    ),
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
                  // margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prochain entretien',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(
                        color: Colors.white54,
                        height: screenWidth * 0.05,
                      ),
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
                                      fontSize: screenWidth * 0.03,
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
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, [Widget? destination]) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        /* Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Ouverture: $title"))); */
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
    );
  }

  Widget _buildContainerRow(
    IconData icon,
    String title, [
    Widget? destination,
  ]) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: Container(
        // padding: EdgeInsets.all(16),
        // margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
              Icon(icon, color: Colors.amber, size: screenWidth * 0.08),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
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
