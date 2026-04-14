import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sunnypool_app/models/pool_model.dart';
import 'package:sunnypool_app/models/product_model.dart';
import 'package:sunnypool_app/models/user_model.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';
import 'package:sunnypool_app/screens/login_screen.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/services/product_service.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
import 'package:sunnypool_app/utils/user_location.dart';
import 'package:sunnypool_app/widget/custom_stepper.dart';

class AddPiscineScreen extends StatefulWidget {
  final Function(Pool)? onAddPool;

  const AddPiscineScreen({super.key, this.onAddPool});

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
  bool _isSubmitting = false;

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

  File? photoFace;
  File? photoNoticeDosage;

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

  Future<void> _submitPool() async {
    if (!_validateCurrentStep(showError: true)) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

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
        codePostal: int.tryParse(codePostalController.text) ?? 0,
        pays: paysController.text,
        ville: villeController.text,
      ),
    );
    try {
      final token = await TokenStorage.getToken();
      await PoolService().addPool(token.toString(), newPool).catchError((
        error,
      ) {
        if (error is ApiException && error.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expirée. Veuillez vous reconnecter.'),
              backgroundColor: Colors.red,
            ),
          );
          TokenStorage.clearToken().then((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          });
        }
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Piscine ajoutée avec succès.'),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.onAddPool == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen()),
        );
      } else {
        widget.onAddPool!(newPool);
        Navigator.pop(context);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de l\'ajout. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    // }
  }

  void _showStepError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  bool _validateCurrentStep({bool showError = false}) {
    if (_currentStep == 0) {
      final length = double.tryParse(lengthController.text) ?? 0;
      final width = double.tryParse(widthController.text) ?? 0;
      final depth = double.tryParse(depthController.text) ?? 0;

      if (nameController.text.trim().isEmpty) {
        if (showError) _showStepError('Renseignez le nom de la piscine.');
        return false;
      }
      if (length <= 0 || width <= 0 || depth <= 0) {
        if (showError) {
          _showStepError(
            'Renseignez des dimensions valides (longueur, largeur, profondeur).',
          );
        }
        return false;
      }
    }

    if (_currentStep == 1 && traitementChecked.isEmpty) {
      if (showError) _showStepError('Sélectionnez au moins un traitement.');
      return false;
    }

    if (_currentStep == 3) {
      final hasAddress =
          adresseController.text.trim().isNotEmpty &&
          codePostalController.text.trim().isNotEmpty &&
          villeController.text.trim().isNotEmpty &&
          paysController.text.trim().isNotEmpty;
      final validPostal =
          int.tryParse(codePostalController.text.trim()) != null;

      if (!hasAddress || !validPostal) {
        if (showError) {
          _showStepError(
            'Complétez la localisation avec un code postal valide.',
          );
        }
        return false;
      }
    }

    return true;
  }

  void _nextStep() {
    if (!_validateCurrentStep(showError: true)) return;
    if (_currentStep < 4) {
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
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une piscine'),
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
        child: Column(
          spacing: 20,
          children: [
            Column(
              children: [
                Image.asset('assets/logo.png', height: screenHeight / 12),
                Text(
                  'Ajouter votre piscine.',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.amber,
                  ),
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
      ),
    );
  }

  Widget _buildFormPool() {
    final screenWidth = MediaQuery.of(context).size.width;

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
                  initialValue: typePool,
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
                              initialValue: false,
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
                              initialValue: BondeFond.non,
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
                                initialValue: Pompe.standard,
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
                                initialValue: TypeFiltre.sable,
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
                    SizedBox(
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
                                    backgroundColor: WidgetStateProperty.all(
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

    Widget buildTextField(
      IconData icon,
      String title,
      TextEditingController? controller, {
      bool obscure = false,
      String? Function(String?)? validator,
    }) {
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
          buildTextField(Icons.home, 'Adresse', adresseController),
          buildTextField(Icons.post_add, 'Code postal', codePostalController),
          buildTextField(Icons.location_city, 'Ville', villeController),
          buildTextField(Icons.public, 'Pays', paysController),
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

  Widget buildAddProduct() {
    final theme = Theme.of(context);

    final _nameController = TextEditingController();
    final _brandController = TextEditingController();
    final _quantityController = TextEditingController();
    final _unitController = TextEditingController();

    final ImagePicker _picker = ImagePicker();

    Categorie? _selectedCategory;

    _AddProduct() {
      print("AddProduct constructor called");
      print("Name product: ${_nameController.text}");
      print("Brand product: ${_brandController.text}");
      print("Selected category: $_selectedCategory");

      final quantity = int.tryParse(_quantityController.text.trim());
      final unit = _unitController.text.trim();

      if (_nameController.text.isEmpty ||
          _brandController.text.isEmpty ||
          _selectedCategory == null ||
          quantity == null ||
          quantity < 0 ||
          unit.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez remplir tous les champs obligatoires."),
          ),
        );
        return;
      }

      var product = ProductModel(
        categorie: _selectedCategory!,
        marque: _brandController.text,
        name: _nameController.text,
        quantity: quantity,
        unit: unit,
        photoFace: photoFace?.path,
        photoNoticeDosage: photoNoticeDosage?.path,
      );

      TokenStorage.getToken().then((tokenValue) {
        ProductService()
            .addProduct(tokenValue!, product)
            .then((response) {
              if (response['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Produit ajouté avec succès !")),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur : ${response['message']}")),
                );
              }
            })
            .catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erreur de connexion : $error")),
              );
            });
      });
    }

    Future<void> _takePhotoProd(String imageType) async {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          switch (imageType) {
            case 'Face avant':
              photoFace = File(photo.path);
              break;
            case 'Étiquette':
              photoNoticeDosage = File(photo.path);
              break;
          }
        });
      }
    }

    Widget _buildSectionCard({required String title, required Widget child}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withOpacity(0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
    }

    Widget _buildPhotoButton({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
    }) {
      return SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.black),
          label: Text(label),
        ),
      );
    }

    Widget _buildInputLabel(ThemeData theme, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: theme.textTheme.bodyLarge),
      );
    }

    InputDecoration _inputDecoration(String hint) {
      return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF222222),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF050505), Color(0xFF111111)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /* Text(
                'Ajout d\'un Produit',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
  
              const SizedBox(height: 16), */

              /* _buildSectionCard(
                title: 'Scanner automatiquement',
                child: Column(
                  children: [
                    const Icon(
                      Icons.document_scanner,
                      color: Colors.amber,
                      size: 30,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.photo_camera,
                          color: Colors.black,
                        ),
                        label: const Text('Photographier l\'étiquette'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sunny remplit automatiquement les dosages et la composition.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14), */

              _buildSectionCard(
                title: 'Informations produit',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(theme, 'Nom du produit'),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration('Ex: Chlore choc 5kg'),
                    ),
                    const SizedBox(height: 10),
                    _buildInputLabel(theme, 'Marque'),
                    TextField(
                      controller: _brandController,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration('Ex: Bayrol'),
                    ),
                    const SizedBox(height: 10),
                    _buildInputLabel(theme, 'Catégorie'),
                    DropdownButtonFormField<Categorie>(
                      value: _selectedCategory,
                      dropdownColor: const Color(0xFF1A1A1A),
                      iconEnabledColor: Colors.amber,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        'Sélectionnez une catégorie',
                      ),
                      items: Categorie.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    _buildInputLabel(theme, 'Quantité'),
                    TextField(
                      controller: _quantityController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration('Ex: 5'),
                    ),
                    const SizedBox(height: 10),

                    _buildInputLabel(theme, 'Unité'),
                    TextField(
                      controller: _unitController,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.done,
                      decoration: _inputDecoration('Ex: kg, g, L'),
                    ),
                    const SizedBox(height: 10),

                    //_buildInputLabel(theme, 'Concentration'),
                    /* TextField(
                        controller: _concentrationController,
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.done,
                        decoration: _inputDecoration('Ex: 56%'),
                      ), */
                  ],
                ),
              ),

              _buildSectionCard(
                title: 'Photos du produit',
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPhotoButton(
                        icon: Icons.add_a_photo,
                        label: 'Face avant',
                        onPressed: () => _takePhotoProd('Face avant'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildPhotoButton(
                        icon: Icons.text_snippet,
                        label: 'Étiquette',
                        onPressed: () => _takePhotoProd('Étiquette'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              const SizedBox(height: 18),

              /* SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _AddProduct,
                  child: Text(
                    'Ajouter ce produit',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Annuler',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final List<String> steps = [
      "Piscine",
      "Traitements",
      "Photos",
      "Localisation",
      "Produit",
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Étape ${_currentStep + 1} / ${steps.length} • ${steps[_currentStep]}',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / steps.length,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.white12,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          CustomStepper(
            currentStep: _currentStep,
            steps: steps,
            onStepTapped: (index) {
              if (index <= _currentStep) {
                setState(() => _currentStep = index);
                return;
              }
              if (_validateCurrentStep(showError: true)) {
                setState(() => _currentStep = index);
              }
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
                4 => buildAddProduct(),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        /* padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16), */
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        side: BorderSide(color: Colors.amber, width: 1),
                      ),
                      child: Text(
                        "Retour",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : SizedBox.shrink(),
              _currentStep < steps.length - 1
                  ? ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        /* padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16), */
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        side: BorderSide(color: Colors.amber, width: 1),
                      ),
                      child: Text(
                        "Suivant",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitPool,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        /* padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16), */
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        side: BorderSide(color: Colors.amber, width: 1),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              "Ajouter",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
