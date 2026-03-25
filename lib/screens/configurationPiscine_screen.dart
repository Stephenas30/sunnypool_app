import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';

class ConfigurationpiscineScreen extends StatefulWidget {
  const ConfigurationpiscineScreen({Key? key}) : super(key: key);

  @override
  _ConfigurationpiscineScreen createState() {
    return _ConfigurationpiscineScreen();
  }
}

class _ConfigurationpiscineScreen extends State<ConfigurationpiscineScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  String? namePool;
  String? typePool = "Béton";
  double? lengthPool;
  double? widthPool;
  double? depthPool;
  double volumePool = 23;
  List<String> traitementChecked = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 150),
              Text(
                'Bienvenue!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                'Configurons votre piscine pour un suivi optimal.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Nom de la piscine',
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 116, 116, 116),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      // Text('Type piscine'),
                      // SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: typePool,
                        style: TextStyle(color: Colors.white),
                        dropdownColor: const Color.fromARGB(128, 255, 214, 64),
                        decoration: InputDecoration(
                          labelText: "Type de piscine",
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        items: ["Coque", "Béton", "Liner", "Autre"]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            typePool = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Veuillez sélectionner une option";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          ...['Longueur', 'Largeur', 'Profondeur'].map(
                            (item) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: item,
                                    hintStyle: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        116,
                                        116,
                                        116,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: volumePool,
                              min: 0,
                              max: 100,
                              divisions: 10,
                              label: volumePool.toString(),
                              activeColor: Colors.blue,
                              inactiveColor: Colors.grey,
                              onChanged: (value) {
                                setState(() {
                                  volumePool = value;
                                });
                              },
                            ),
                          ),

                          Text('${volumePool.toString()} m3'),
                          SizedBox(width: 20),
                        ],
                      ),
                      Text('Traitement'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: ['Chlore', 'Brome', 'Sel']
                            .map(
                              (item) => Expanded(
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      traitementChecked.contains(item)
                                          ? Colors.amber
                                          : Colors.transparent,
                                    ),
                                    foregroundColor: MaterialStateProperty.all(
                                      Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (!traitementChecked.contains(item)) {
                                        traitementChecked.add(item);
                                      } else {
                                        traitementChecked.remove(item);
                                      }
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: traitementChecked.contains(item)
                                          ? Colors.amber
                                          : Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: traitementChecked.contains(
                                            item,
                                          ),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                if (!traitementChecked.contains(
                                                  item,
                                                )) {
                                                  traitementChecked.add(item);
                                                }
                                              } else {
                                                traitementChecked.remove(item);
                                              }
                                            });
                                          },
                                        ),
                                        Text(item),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print('Nom de la piscine: ${nameController.text}');
                  print('Volume de la piscine: ${volumePool.toString()}');
                  print('Traitement: ${traitementChecked.join('-')} ');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => DashboardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                ),
                child: Text(
                  'Continuer',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 99, 99, 99),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: Text(
                  'Passer',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
