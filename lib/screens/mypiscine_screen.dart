import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/pool_model.dart';
import 'package:sunnypool_app/models/user_model.dart';
import 'package:sunnypool_app/screens/add_piscine_screen.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/utils/list_piscine.dart';
import 'package:sunnypool_app/utils/token_storage.dart';

double parseDouble(dynamic value) {
  if (value == null) return 0.0; // ou null selon ton besoin
  if (value is num) return value.toDouble(); // déjà un int/double
  if (value is String) return double.tryParse(value) ?? 0.0; // parse String
  return 0.0; // valeur par défaut si autre type inattendu
}

class MypiscineScreen extends StatefulWidget {
  const MypiscineScreen({super.key});

  @override
  State<MypiscineScreen> createState() => _MypiscineScreen();
}

class _MypiscineScreen extends State<MypiscineScreen> {
  List<Pool> piscines = listPiscines;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    List<Pool> fetchPool = [];
    TokenStorage.getToken().then((tokenValue) {
      print(tokenValue);
      PoolService().getAllPool(tokenValue.toString()).then((
        Map<String, dynamic> pools,
      ) {
        List.generate(pools['data'].length, (item) {
          print(pools['data'][item]);
          Pool pool = Pool(
            name: pools['data'][item]['name'],
            type:
                /* pools['data'][item]['caracteristiques']['type'] ?? */
                TypePool.beton,
            dimension: Dimension(
              length: parseDouble(pools['data'][item]['dimension']['length']),
              width: parseDouble(pools['data'][item]['dimension']['width']),
              depth: parseDouble(pools['data'][item]['dimension']['depth']),
            ),
            location: Location(
              latitude: parseDouble(
                pools['data'][item]['location']['latitude'],
              ),
              longitude: parseDouble(
                pools['data'][item]['location']['longitude'],
              ),
            ),
          );
          fetchPool.add(pool);
        });
        print(fetchPool);
        setState(() {
          piscines = fetchPool;
        });
      });
    });
  }

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
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(height: 20),
              Column(
                children: [
                  Image.asset("assets/logo.png", height: 150),
                  Text(
                    "Liste de vos piscines",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
                child: ListView.builder(
                  itemCount: piscines.length,
                  itemBuilder: (context, index) {
                    return _buildListPool(piscines[index]);
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

  Widget _buildListPool(Pool pool) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.all(6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(81, 255, 193, 7), // pas de fond
          shadowColor: Colors.amber, // pas d’ombre
          elevation: 0, // supprime l'élévation
          padding: EdgeInsets.zero, // supprime le paddin
          side: BorderSide(color: Colors.amber, width: 2),
        ),
        onPressed: () {
          // Naviguer vers les détails de la piscine
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DashboardScreen(pool: pool)),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                bottomLeft: Radius.circular(50),
              ),
              child: /* image.toString() != 'null' ? Image.file(
                        image!,
                        fit: BoxFit.cover,
                        height: screenHeight * 0.08,
                        width: screenWidth * 0.5,
                      ) : */ Image.asset(
                'assets/piscine.png',
                fit: BoxFit.cover,
                height: screenHeight * 0.08,
                width: screenWidth * 0.3,
              ),
            ),
            //Image.asset('assets/piscine.png', height: screenHeight * 0.08),
            SizedBox(width: 20),
            Text(
              pool.name,
              style: TextStyle(
                color: Colors.amber,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
