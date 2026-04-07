import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/pool_model.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';

class ConfigurationpiscineScreen extends StatefulWidget {
  final Pool? pool;
  final List<String> traitementChecked;

  const ConfigurationpiscineScreen({
    Key? key,
    this.pool,
    this.traitementChecked = const ['Chlore'],
  }) : super(key: key);

  @override
  _ConfigurationpiscineScreen createState() {
    return _ConfigurationpiscineScreen();
  }
}

class _ConfigurationpiscineScreen extends State<ConfigurationpiscineScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final depthController = TextEditingController();

  TypePool? typePool;
  double? volumePool;
  List<String> traitementChecked = ['Chlore'];

  @override
  void initState() {
    super.initState();
    typePool = widget.pool?.type;
    volumePool = widget.pool?.volume;
    nameController.text = widget.pool?.name ?? '';
    lengthController.text = widget.pool?.dimension.length.toString() ?? '';
    widthController.text = widget.pool?.dimension.width.toString() ?? '';
    depthController.text = widget.pool?.dimension.depth.toString() ?? '';
    traitementChecked = widget.traitementChecked;
  }

  void onChangedVolume() {
    final length = double.tryParse(lengthController.text) ?? 0;
    final width = double.tryParse(widthController.text) ?? 0;
    final depth = double.tryParse(depthController.text) ?? 0;
    setState(() {
      volumePool = length * width * depth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: nameController.text.isEmpty
              ? EdgeInsets.all(10)
              : EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: nameController.text.isEmpty ? MediaQuery.of(context).size.height : 0,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset('assets/logo.png', height: screenHeight / 6),
                      nameController.text.isEmpty
                          ? Text(
                              'Bienvenue!',
                              style: TextStyle(
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : SizedBox.shrink(),
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
                            DropdownButtonFormField<TypePool>(
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
                              items: TypePool.values
                                  .map(
                                    (type) => DropdownMenuItem<TypePool>(
                                      value: type,
                                      child: Text(
                                        type.toString().split('.').last,
                                      ),
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
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: TextField(
                                      controller: lengthController,
                                      decoration: InputDecoration(
                                        hintText: 'Longueur (m)',
                                        labelText: 'Longueur (m)',
                                        labelStyle: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            116,
                                            116,
                                            116,
                                          ),
                                          fontSize: screenWidth * 0.03,
                                        ),
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
                                      onChanged: (value) => onChangedVolume()
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: TextField(
                                      controller: widthController,
                                      decoration: InputDecoration(
                                        hintText: 'Largeur (m)',
                                        labelText: 'Largeur (m)',
                                        labelStyle: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            116,
                                            116,
                                            116,
                                          ),
                                          fontSize: screenWidth * 0.03,
                                        ),
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
                                      onChanged: (value) => onChangedVolume()
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: TextField(
                                      controller: depthController,
                                      decoration: InputDecoration(
                                        hintText: 'Profondeur (m)',
                                        labelText: 'Profondeur (m)',
                                        labelStyle: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            116,
                                            116,
                                            116,
                                          ),
                                          fontSize: screenWidth * 0.03,
                                        ),
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
                                      onChanged: (value) => onChangedVolume()
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                /* Expanded(
                                  child: Slider(
                                    value: volumePool ?? 0,
                                    min: 0,
                                    max: 100,
                                    divisions: 10,
                                    label: volumePool?.toString() ?? '0',
                                    activeColor: Colors.blue,
                                    inactiveColor: Colors.grey,
                                    onChanged: (value) {
                                      // setState(() {
                                      //   volumePool = value;
                                      // });
                                    },
                                  ),
                                ), */

                                Text('${volumePool.toString()} m3'),
                                //SizedBox(width: 20),
                              ],
                            ),
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
                                children: ['Chlore', 'Brome', 'Sel', 'Autre']
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
