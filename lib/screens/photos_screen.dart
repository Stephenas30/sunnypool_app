import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/analyse_model.dart';
import 'package:sunnypool_app/models/photo_model.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';
import 'package:sunnypool_app/services/analyse_service.dart';
import 'package:sunnypool_app/utils/poolId_storage.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
import 'package:sunnypool_app/widget/pick_image.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() {
    // TODO: implement createState
    return _PhotosScreenState();
  }
}

class _PhotosScreenState extends State<PhotosScreen> {
  final _surfaceSoftColor = Color(0xFF1E1E1E);
  final _borderColor = Color(0x33FFD54F);
  static const int _pollMaxAttempts = 25;
  static const Duration _pollInterval = Duration(seconds: 2);

  File? image_ensemble;
  File? image_eau;
  File? image_local;
  File? image_equipements;

  void _takePhoto(String imageType) {
    PickImage(
      onImagePicked: (photo) {
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
      },
      context: context,
    ).showImageSourceSheet();
    /* final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
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
    } */
  }

  bool _isSubmitting = false;

  List<PhotoModel> _selectedPhotos() {
    final photos = <PhotoModel>[];

    if (image_ensemble != null) {
      photos.add(
        PhotoModel(
          title: 'Vue d\'ensemble',
          imageType: 'overview',
          file: image_ensemble!,
        ),
      );
    }
    if (image_eau != null) {
      photos.add(
        PhotoModel(
          title: 'Eau de la piscine',
          imageType: 'water',
          file: image_eau!,
        ),
      );
    }
    if (image_local != null) {
      photos.add(
        PhotoModel(
          title: 'Local technique',
          imageType: 'technical_room',
          file: image_local!,
        ),
      );
    }
    if (image_equipements != null) {
      photos.add(
        PhotoModel(
          title: 'Equipements',
          imageType: 'equipments',
          file: image_equipements!,
        ),
      );
    }

    return photos;
  }

  Future<String> _pollUntilCompleted(String token, String analyseId) async {
    for (int attempt = 0; attempt < _pollMaxAttempts; attempt++) {
      final res = await AnalyseService().responseAnalyse(token, analyseId);
      final found = res['found'] == true;

      if (found) {
        final response = (res['response'] ?? '').toString().trim();
        if (response.isNotEmpty) {
          return response;
        }
      }

      await Future.delayed(_pollInterval);
    }

    throw TimeoutException('Polling timeout');
  }

  Future<void> _analyse() async {
    if (_isSubmitting) return;

    final selectedPhotos = _selectedPhotos();
    if (selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ajoutez au moins une photo avant de lancer l\'analyse',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final tokenValue = await TokenStorage.getToken();
      if (tokenValue == null || tokenValue.isEmpty) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }

      final poolIdValue = await PoolIdStorage.getPoolId();
      final poolId = int.tryParse(poolIdValue ?? '');
      if (poolId == null) {
        throw Exception('Aucune piscine sélectionnée.');
      }

      final response = await AnalyseService().sendAnalysePhoto(
        tokenValue,
        AnalyseModel(pool_id: poolId, images: _selectedPhotos()),
      );

      final analyseId = response['analyse_id']?.toString();

      final finalResponse = await _pollUntilCompleted(tokenValue, analyseId!);

      if (!mounted) return;

      print(finalResponse);

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Résultat de l\'analyse'),
            content: SingleChildScrollView(
              child: SelectableText(finalResponse),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'analyse: $error'),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos Piscine'),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: (screenWidth * 0.3).clamp(90.0, 160.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Ajoutez des photos de votre piscine pour une analyse précise.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final gridCount = constraints.maxWidth < 430 ? 1 : 2;
                        return GridView.count(
                          crossAxisCount: gridCount,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: gridCount == 1 ? 2.4 : 1.1,
                          children: [
                            _buildCardPhoto('Vue d\'ensemble', image_ensemble),
                            _buildCardPhoto('Eau de la piscine', image_eau),
                            _buildCardPhoto('Local technique', image_local),
                            _buildCardPhoto('Equipements', image_equipements),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.25),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Conseil',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (screenWidth * 0.05).clamp(18.0, 24.0),
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Prenez des photos nettes et lumineuses',
                            style: TextStyle(
                              fontSize: (screenWidth * 0.033).clamp(12.0, 15.0),
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Montrez la pompe, le skimmer, le robot',
                            style: TextStyle(
                              fontSize: (screenWidth * 0.033).clamp(12.0, 15.0),
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'L\'IA analysera votre piscine automatiquement',
                            style: TextStyle(
                              fontSize: (screenWidth * 0.033).clamp(12.0, 15.0),
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    /* ElevatedButton(
                onPressed: () {
                  print('Confirmer et continuer');
                  print('Image ensemble: ${image_ensemble?.path}');
                  print('Image eau: ${image_eau?.path}');
                  print('Image local: ${image_local?.path}');
                  print('Image equipements: ${image_equipements?.path}');
                },
                child: Text(
                  'Confirmer et continuer',
                  style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Passer cette étape',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ), */
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _analyse,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.check_circle),
                        label: Text(
                          _isSubmitting ? 'Analysé...' : 'Analyser',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardPhoto(String title, File? image) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _takePhoto(title),
        child: Container(
          decoration: BoxDecoration(
            color: _surfaceSoftColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      image != null
                          ? Image.file(image, fit: BoxFit.cover)
                          : Image.asset(
                              'assets/piscine.png',
                              fit: BoxFit.cover,
                            ),
                      Container(color: Colors.black.withValues(alpha: 0.35)),
                      const Center(
                        child: Icon(
                          Icons.photo_camera,
                          color: Colors.amber,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      image != null ? 'Modifiée' : 'Ajouter',
                      style: const TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* Widget _buildCardPhoto(String title,File? image) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(padding: EdgeInsets.all(8), 
      //padding: EdgeInsets.all(8),
      child: ElevatedButton(
      /* margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ), */
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF151515),
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber.withOpacity(0.4)),
        ),
      ),
      onPressed: () {
        _takePhoto(title);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: screenWidth*0.03, color: Colors.white),),
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
                      child: image.toString() != 'null' ? Image.file(
                        image!,
                        fit: BoxFit.cover,
                        height: screenHeight * 0.08,
                        width: screenWidth * 0.5,
                      ) : Image.asset(
                        'assets/piscine.png',
                        fit: BoxFit.cover,
                        height: screenHeight * 0.08,
                        width: screenWidth * 0.5,
                      ),
                    ),
                  ),
                  Text('Ajouter une photo', style: TextStyle(fontSize: screenWidth*0.03, color: Colors.white),),
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
    )
    );
  } */
}
