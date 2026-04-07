import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sunnypool_app/models/pool_model.dart';
import 'package:sunnypool_app/models/user_model.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
import 'package:sunnypool_app/utils/user_location.dart';
import 'package:sunnypool_app/widget/custom_stepper.dart';

class AddPiscineScreen extends StatefulWidget {
  final Function(Pool)? onAddPool;

  const AddPiscineScreen({Key? key, this.onAddPool}) : super(key: key);

  @override
  _AddPiscineScreen createState() {
    return _AddPiscineScreen();
  }
}

class _AddPiscineScreen extends State<AddPiscineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;

  final nameController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final depthController = TextEditingController();

  final nbrSkimmersController = TextEditingController();
  final nbrRefoulementController = TextEditingController();
  final puissancePompeController = TextEditingController();

  final adresseController = TextEditingController();
  final codePostalController = TextEditingController();
  final villeController = TextEditingController();
  final paysController = TextEditingController();

  Pool? pool;

  TypePool typePool = TypePool.beton;
  double? volumePool;

  bool priseBalai = false;
  BondeFond bondeFond = BondeFond.non;
  Pompe pompe = Pompe.standard;
  TypeFiltre typeFiltre = TypeFiltre.sable;

  List<Traitement> traitementChecked = [Traitement.chlore];

  File? image_ensemble;
  File? image_eau;
  File? image_local;
  File? image_equipements;

  Location? location;

  Future<void> _takePhoto(String imageType) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        switch (imageType) {
          case 'Vue d\'ensemble':
            image_ensemble = File(photo.path);
            break;
          case 'Eau de la piscine':
            image_eau = File(photo.path);
            break;
          case 'Local technique':
            image_local = File(photo.path);
            break;
          case 'Equipements':
            image_equipements = File(photo.path);
            break;
        }
      });
    }
  }

  void _submitPool() {
    /*     if (_formKey.currentState!.validate() &&
        _formKey2.currentState!.validate()) { */
    final newPool = Pool(
      name: nameController.text,
      type: typePool,
      dimension: Dimension(
        length: double.tryParse(lengthController.text) ?? 0,
        width: double.tryParse(widthController.text) ?? 0,
        depth: double.tryParse(depthController.text) ?? 0,
      ),
      traitements: traitementChecked,
      /* .map((t) => Traitement(type: t, dateDernierTraitement: DateTime.now()))
            .toList(), */
      hydraulique: Hydraulique(
        skimmers: int.tryParse(nbrSkimmersController.text) ?? 0,
        refoulement: int.tryParse(nbrRefoulementController.text) ?? 0,
        priseBalai: priseBalai,
        bondeFond: bondeFond,
      ),
      filtration: Filtration(
        pompe: pompe,
        puissance: double.tryParse(puissancePompeController.text) ?? 0,
        type: typeFiltre,
      ),
      photoPool: PhotoPool(
        photoBassin: image_ensemble?.path ?? '',
        photoEnvironnement: image_eau?.path ?? '',
        photoLocalTechn: image_local?.path ?? '',
      ),
      location: Location(
        latitude: location?.latitude ?? 0,
        longitude: location?.longitude ?? 0,
        adresse: adresseController.text,
        codePostal: int.parse(codePostalController.text),
        pays: paysController.text,
        ville: villeController.text,
      ),
    );
    //print(newPool.getPool);
    TokenStorage.getToken().then(
      (token) => PoolService()
          .addPool(token.toString(), newPool)
          .then(
            (value) => {
              print(value),

              widget.onAddPool == null
                  ? {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => DashboardScreen()),
                      ),
                    }
                  : {widget.onAddPool!(newPool), Navigator.pop(context)},
            },
          ),
    );

    // }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter une piscine',
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
      body: Column(
        spacing: 20,
        children: [
          Column(
            children: [
              Image.asset('assets/logo.png', height: screenHeight / 12),
              Text(
                'Ajouter votre piscine.',
                style: TextStyle(fontSize: screenWidth * 0.05),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 20),
                Expanded(child: _buildStepper()),
                SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPool() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    void onChangedVolume() {
      final length = double.tryParse(lengthController.text) ?? 0;
      final width = double.tryParse(widthController.text) ?? 0;
      final depth = double.tryParse(depthController.text) ?? 0;
      setState(() {
        volumePool = length * width * depth;
      });
    }

    return SingleChildScrollView(
      child: /* Padding(
          //padding: EdgeInsets.all(8),
          child: */ ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height / 2,
        ),
        child: IntrinsicHeight(
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 30,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Nom de la piscine',
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 116, 116, 116),
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
                      borderSide: BorderSide(color: Colors.amber, width: 2),
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
                  dropdownColor: const Color.fromARGB(128, 255, 214, 64),
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
                      borderSide: BorderSide(color: Colors.amber, width: 2),
                    ),
                  ),
                  items: TypePool.values
                      .map(
                        (type) => DropdownMenuItem<TypePool>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      typePool = value ?? TypePool.beton;
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
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          controller: lengthController,
                          decoration: InputDecoration(
                            hintText: 'Longueur (m)',
                            labelText: 'Longueur (m)',
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 116, 116, 116),
                              fontSize: screenWidth * 0.03,
                            ),
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 116, 116, 116),
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.03,
                          ),
                          onChanged: (value) => onChangedVolume(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          controller: widthController,
                          decoration: InputDecoration(
                            hintText: 'Largeur (m)',
                            labelText: 'Largeur (m)',
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 116, 116, 116),
                              fontSize: screenWidth * 0.03,
                            ),
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 116, 116, 116),
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.03,
                          ),
                          onChanged: (value) => onChangedVolume(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          controller: depthController,
                          decoration: InputDecoration(
                            hintText: 'Profondeur (m)',
                            labelText: 'Profondeur (m)',
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 116, 116, 116),
                              fontSize: screenWidth * 0.03,
                            ),
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 116, 116, 116),
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.03,
                          ),
                          onChanged: (value) => onChangedVolume(),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: volumePool ?? 0,
                        min: 0,
                        max: 1000,
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
                    ),

                    Text('${volumePool.toString()} m3'),
                    SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormTraitement() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: /* Padding(
          //padding: EdgeInsets.all(8),
          child: */ ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height / 2,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 50,
            children: [
              IntrinsicHeight(
                child: Column(
                  spacing: 30,
                  children: [
                    Column(
                      spacing: 20,
                      children: [
                        Text(
                          'Hydraulique',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: TextField(
                                  controller: nbrSkimmersController,
                                  decoration: InputDecoration(
                                    hintText: 'Nbr de skimmers',
                                    labelText: 'Nbr de skimmers',
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
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: TextField(
                                  controller: nbrRefoulementController,
                                  decoration: InputDecoration(
                                    hintText: 'Nbr de refoulement',
                                    labelText: 'Nbr de refoulement',
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
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          spacing: 20,
                          children: [
                            /* Expanded(
                              child:  */
                            DropdownButtonFormField<bool>(
                              value: false,
                              style: TextStyle(color: Colors.white),
                              dropdownColor: const Color.fromARGB(
                                128,
                                255,
                                214,
                                64,
                              ),
                              decoration: InputDecoration(
                                labelText: "Prise balai",
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
                              items: [true, false]
                                  .map(
                                    (value) => DropdownMenuItem<bool>(
                                      value: value,
                                      child: Text(value ? "Oui" : "Non"),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  priseBalai = value ?? false;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Veuillez sélectionner une option";
                                }
                                return null;
                              },
                              // ),
                            ),
                            /* Expanded(
                              child:  */
                            DropdownButtonFormField<BondeFond>(
                              value: BondeFond.non,
                              style: TextStyle(color: Colors.white),
                              dropdownColor: const Color.fromARGB(
                                128,
                                255,
                                214,
                                64,
                              ),
                              decoration: InputDecoration(
                                labelText: "Bonde de fond",
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
                              items: BondeFond.values
                                  .map(
                                    (value) => DropdownMenuItem<BondeFond>(
                                      value: value,
                                      child: Text(
                                        value == BondeFond.horizontale
                                            ? "Horizontale"
                                            : value == BondeFond.verticale
                                            ? "Verticale"
                                            : "Non",
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  bondeFond = value ?? BondeFond.non;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Veuillez sélectionner une option";
                                }
                                return null;
                              },
                            ),
                            // ),
                          ],
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        Text(
                          'Filtration',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<Pompe>(
                                value: Pompe.standard,
                                style: TextStyle(color: Colors.white),
                                dropdownColor: const Color.fromARGB(
                                  128,
                                  255,
                                  214,
                                  64,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Pompe",
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
                                items: Pompe.values
                                    .map(
                                      (value) => DropdownMenuItem<Pompe>(
                                        value: value,
                                        child: Text(
                                          value.toString().split('.').last,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    pompe = value ?? Pompe.standard;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return "Veuillez sélectionner une option";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: TextField(
                                  controller: puissancePompeController,
                                  decoration: InputDecoration(
                                    hintText: 'Puissance de Pompe',
                                    labelText: 'Puissance de Pompe',
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
                                ),
                              ),
                            ),
                            Expanded(
                              child: DropdownButtonFormField<TypeFiltre>(
                                value: TypeFiltre.sable,
                                style: TextStyle(color: Colors.white),
                                dropdownColor: const Color.fromARGB(
                                  128,
                                  255,
                                  214,
                                  64,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Type de filtre",
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
                                items: TypeFiltre.values
                                    .map(
                                      (value) => DropdownMenuItem<TypeFiltre>(
                                        value: value,
                                        child: Text(
                                          value.toString().split('.').last,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    typeFiltre = value ?? TypeFiltre.sable;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return "Veuillez sélectionner une option";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 10,
                        children: Traitement.values
                            .map(
                              (item) => Expanded(
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      traitementChecked.contains(item)
                                          ? Colors.amber
                                          : Colors.transparent,
                                    ),
                                    foregroundColor: WidgetStateProperty.all(
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
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.03,
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormPhoto() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: screenWidth,
        maxHeight: screenHeight / 2,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildCardPhoto('Vue d\'ensemble', image_ensemble),
          _buildCardPhoto('Eau de la piscine', image_eau),
          _buildCardPhoto('Local technique', image_local),
          _buildCardPhoto('Equipements', image_equipements),
        ],
      ),
    );
  }

  Widget _buildCardPhoto(String title, File? image) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.all(8),
      //padding: EdgeInsets.all(8),
      child: ElevatedButton(
        /* margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ), */
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.amber),
          ),
        ),
        onPressed: () {
          _takePhoto(title);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.white,
              ),
            ),
            Stack(
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: image.toString() != 'null'
                            ? Image.file(
                                image!,
                                fit: BoxFit.cover,
                                height: screenHeight * 0.08,
                                width: screenWidth * 0.5,
                              )
                            : Image.asset(
                                'assets/piscine.png',
                                fit: BoxFit.cover,
                                height: screenHeight * 0.08,
                                width: screenWidth * 0.5,
                              ),
                      ),
                    ),
                    Text(
                      'Ajouter une photo',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                Align(
                  alignment: Alignment(0, 1), // relatif
                  child: Container(
                    padding: EdgeInsets.all(5),
                    // color: Colors.black.withOpacity(0.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: const Color.fromARGB(216, 255, 211, 50),
                    ),
                    child: Icon(
                      Icons.photo_camera,
                      color: const Color.fromARGB(255, 154, 116, 0),
                      size: screenWidth * 0.07,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLocation() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isLoadingLocation = false;
    bool locationChecked = false;

    void loadLocation() async {
      try {
        setState(() {
          isLoadingLocation = true;
        });
        Map<String, String?> address = await getFullAddress();

        if (address.isNotEmpty) {
          setState(() {
            isLoadingLocation = false;
            locationChecked = true;
            location = Location(
              latitude: double.parse(address['latitude'] ?? '0'),
              longitude: double.parse(address['longitude'] ?? '0'),
              adresse: address['street'] ?? '',
              codePostal: int.parse(address['postalCode'] ?? '0'),
              ville: address['locality'] ?? '',
              pays: address['country'] ?? '',
            );
          });
        }

        adresseController.text = address['street'] ?? '';
        codePostalController.text = address['postalCode'] ?? '';
        villeController.text = address['locality'] ?? '';
        paysController.text = address['country'] ?? '';
      } catch (e) {
        print(e);
      }
    }

    void listenerInput() {
      if (adresseController.text.isNotEmpty &&
          codePostalController.text.isNotEmpty &&
          villeController.text.isNotEmpty &&
          paysController.text.isNotEmpty) {
        setState(() {
          locationChecked = true;
        });
      } else {
        setState(() {
          locationChecked = false;
        });
      }
    }

    Widget _buildTextField(
      IconData icon,
      String title,
      TextEditingController? controller, {
      bool obscure = false,
      String? Function(String?)? validator,
    }) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      return /* Padding(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 8),
      child: */ TextFormField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.amber),
          labelText: title,
          labelStyle: TextStyle(color: Colors.amber),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 2),
          ),
        ),
        onChanged: (value) => listenerInput(),
        validator: validator,
        /* validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            }, */
        // ),
      );
    }

    return Form(
      key: _formKey2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          _buildTextField(Icons.home, 'Adresse', adresseController),
          _buildTextField(Icons.post_add, 'Code postal', codePostalController),
          _buildTextField(Icons.location_city, 'Ville', villeController),
          _buildTextField(Icons.public, 'Pays', paysController),
          /* Padding(
              // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 8),
              child: */
          ElevatedButton(
            onPressed: loadLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              side: BorderSide(color: Colors.amber, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.gps_fixed, color: Colors.white),
                // SizedBox(width: 10),
                Text(
                  'Utiliser ma localisation GPS',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.white,
                  ),
                ),
                isLoadingLocation
                    ? CircularProgressIndicator(
                        color: Colors.amber,
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      )
                    : locationChecked
                    ? Icon(
                        Icons.check_circle_sharp,
                        color: Colors.green[600],
                        size: screenWidth * 0.05,
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          // ),

          /*                     _buildTextField(
                            Icons.gps_fixed,
                            'Utiliser ma localisation GPS',
                            paysController,
                          ), */
          SizedBox(height: 20),
        ],
      ),
    );
    // ),
  }

  Widget _buildStepper() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final List<String> steps = ["Piscine", "Traitements", "Photos", "Ajouter"];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomStepper(
            currentStep: _currentStep,
            steps: steps,
            onStepTapped: (index) {
              setState(() => _currentStep = index);
            },
          ),

          const SizedBox(height: 30),

          Expanded(
            child: Center(
              child: switch (_currentStep) {
                0 => _buildFormPool(),
                1 => _buildFormTraitement(),
                2 => _buildFormPhoto(),
                3 => _buildFormLocation(),
                _ => Container(),
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _currentStep > 0
                  ? ElevatedButton(
                      onPressed: _prevStep,
                      child: Text(
                        "Retour",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        /* padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16), */
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        side: BorderSide(color: Colors.amber, width: 1),
                      ),
                    )
                  : SizedBox.shrink(),
              _currentStep < steps.length - 1
                  ? ElevatedButton(
                      onPressed: _nextStep,
                      child: Text(
                        "Suivant",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        /* padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16), */
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        side: BorderSide(color: Colors.amber, width: 1),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _submitPool,
                      child: Text(
                        "Ajouter",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        /* padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16), */
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        side: BorderSide(color: Colors.amber, width: 1),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
