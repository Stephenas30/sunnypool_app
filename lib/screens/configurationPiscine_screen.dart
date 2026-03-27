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
  List<String> traitementChecked = ['Chlore'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset('assets/logo.png', height: screenHeight / 6),
                      Text(
                        'Bienvenue!',
                        style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Configurons votre piscine pour un suivi optimal.',
                        style: TextStyle(fontSize: screenWidth * 0.03),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ],
                  ),

                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    /* decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ), */
                    child: Form(
                      key: _formKey,
                      child: IntrinsicHeight(
                        child: Column(
                          spacing: 30,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: 'Nom de la piscine',
                                hintStyle: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    116,
                                    116,
                                    116,
                                  ),
                                  // fontSize: screenWidth * 0.03,
                                ),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.amber,
                                  // size: screenWidth * 0.03,
                                ),
                                labelText: 'Nom de la piscine',
                                labelStyle: TextStyle(
                                  color: Colors.amber,
                                  // fontSize: screenWidth * 0.03,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.amber),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.amber,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                // fontSize: screenWidth * 0.03,
                              ),
                            ),
                            // Text('Type piscine'),
                            // SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: typePool,
                              style: TextStyle(color: Colors.white),
                              dropdownColor: const Color.fromARGB(
                                128,
                                255,
                                214,
                                64,
                              ),
                              decoration: InputDecoration(
                                labelText: "Type de piscine",
                                border: OutlineInputBorder(),
                                /* prefixIcon: Icon(Icons.person, color: Colors.amber, size: screenWidth * 0.03), */
                                labelStyle: TextStyle(
                                  color: Colors.amber,
                                  // fontSize: screenWidth * 0.03,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.amber),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.amber,
                                    width: 2,
                                  ),
                                ),
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
                            Row(
                              children: [
                                ...['Longueur', 'Largeur', 'Profondeur'].map(
                                  (item) => Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
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
                                            fontSize: screenWidth * 0.03,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            /* Row(
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
                      ), */
                            Text(
                              'Traitement',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                decoration: TextDecoration.overline,
                              ),
                            ),
                            Container(
                              width: screenWidth,
                              child: Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                spacing: 10,
                                children: ['Chlore', 'Brome', 'Sel']
                                    .map(
                                      (item) => Expanded(
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                  traitementChecked.contains(
                                                        item,
                                                      )
                                                      ? Colors.amber
                                                      : Colors.transparent,
                                                ),
                                            foregroundColor:
                                                WidgetStateProperty.all(
                                                  Colors.white,
                                                ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (!traitementChecked.contains(
                                                item,
                                              )) {
                                                traitementChecked.add(item);
                                              } else {
                                                traitementChecked.remove(item);
                                              }
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  traitementChecked.contains(
                                                    item,
                                                  )
                                                  ? Colors.amber
                                                  : Colors.transparent,
                                            ),
                                            child: Row(
                                              children: [
                                                /* Checkbox(
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
                                        ), */
                                                Expanded(
                                                  child: Text(
                                                    item,
                                                    style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.03,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Column(
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          print('Nom de la piscine: ${nameController.text}');
                          print(
                            'Volume de la piscine: ${volumePool.toString()}',
                          );
                          print('Traitement: ${traitementChecked.join('-')} ');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DashboardScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.01,
                          ),
                        ),
                        child: Text(
                          'Continuer',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            99,
                            99,
                            99,
                          ),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
