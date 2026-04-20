import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sunnypool_app/widget/pick_image.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({Key? key}) : super(key: key);

  @override
  State<PhotosScreen> createState() {
    // TODO: implement createState
    return _PhotosScreenState();
  }
}

class _PhotosScreenState extends State<PhotosScreen> {
  final ImagePicker _picker = ImagePicker();

  File? image_ensemble;
  File? image_eau;
  File? image_local;
  File? image_equipements;

    void _takePhoto(String imageType) {
      print('Prendre une photo pour: $imageType');

      PickImage(onImagePicked: (photo) {
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

      }, context: context).showImageSourceSheet();
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

  _analyse() {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    Map<String, String> valueAnalyse = {
      
    };
    print(valueAnalyse);
    /* TokenStorage.getToken().then((tokenValue) {
      if (sessionId == null) {
        setState(() {
          sessionId = uuid.v4();
        });
      }
      SunnyService()
          .sendChat(
            tokenValue!,
            sessionId!,
            MessageModel(
              message:
                  "Analyser mon eau à partir de ses mesures (ph, chlore, tac, stabilisant, temperature) dans l'analyse de l'eau",
              analyse: valueAnalyse,
            ),
          )
          .then((response) async {
            print(response);
            _isLoading = true;
            try {
              if (response['response'] == "pending") {
                setState(() {
                  _messages.add({
                    'role': 'assistant',
                    'text': 'En cours de traitement. Merci de patienter...',
                  });
                  _isLoading = false;
                });
              }
              final finalResponse = await _pollUntilCompleted(
                tokenValue,
                response['conversation_id'],
              );
              if (!mounted) return;

              setState(() {
                _messages[_messages.length - 1] = {
                  'role': 'assistant',
                  'text': finalResponse,
                };
                _isLoading = false;
                outputAnalyse = finalResponse;
              });
            } catch (error) {
              if (!mounted) return;
              setState(() {
                _messages.add({
                  'role': 'assistant',
                  'text': 'Temps d\'attente dépassé. Merci de réessayer.',
                });
                _isLoading = false;
              });
              print(_messages);
            }
          })
          .catchError((onError) {
            if (!mounted) return;
            print('Error $onError');
          })
          .whenComplete(() {
            if (mounted) {
              setState(() {
                _isSubmitting = false;
                analyseChecked = null;
              });
            }
          });
    }); */
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    

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
        child: Center(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Column(
                children: [
                  Image.asset('assets/logo.png', width: screenWidth * 0.3),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Ajoutez des photos  de votre piscine pour une analyse précise.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Container(
                //height: 1,
                width: double.infinity,
                //color: Colors.white38,
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: screenWidth,
                  maxHeight: screenHeight / 2.3,
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
            ),
              ),
              
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(color: Colors.amber.withOpacity(0.25)),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                padding: EdgeInsets.symmetric(vertical: 8),
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Conseil', textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Prenez des photos nettes et lumineuses',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Montrez la pompe, le skimmer, le robot',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'L\'IA analusera votre piscine automatiquement',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
    );
  }

  Widget _buildCardPhoto(String title,File? image) {
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
  }
}
