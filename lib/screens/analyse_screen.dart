import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunnypool_app/models/analyse_model.dart';
import 'package:sunnypool_app/models/message_model.dart';
import 'package:sunnypool_app/services/analyse_service.dart';
import 'package:sunnypool_app/services/sunny_service.dart';
import 'package:sunnypool_app/utils/poolId_storage.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
import 'package:sunnypool_app/widget/pick_image.dart';
import 'package:uuid/uuid.dart';
import 'profile_screen.dart';

class AnalyseScreen extends StatefulWidget {
  const AnalyseScreen({Key? key}) : super(key: key);

  @override
  State<AnalyseScreen> createState() => _AnalyseScreenState();
}

List<Map<String, String>> listAnalyse = [
  {'name': 'pH', 'value': '7.2', 'unit': ''},
  {'name': 'Chlore', 'value': '1', 'unit': 'ppm'},
  {'name': 'TAC', 'value': '80', 'unit': 'ppm'},
  {'name': 'Stabilisant', 'value': '30', 'unit': 'ppm'},
  {'name': 'Température', 'value': '24', 'unit': '°C'},
];

Map<String, String>? analyseChecked;

class _AnalyseScreenState extends State<AnalyseScreen> {
  final pHController = TextEditingController();
  final chloreController = TextEditingController();
  final tacController = TextEditingController();
  final stabilisantController = TextEditingController();
  final tempController = TextEditingController();

  late List<bool> buttonSelected = [true, false];
  String? sessionId = null;
  final uuid = Uuid();
  bool _isSubmitting = false;
  bool _isLoading = false;
  bool selectedAnalyse = false;

  File? imageBandelette;

  bool _displayOutput = false;
  String outputAnalyse = '';

  static const int _pollMaxAttempts = 25;
  static const Duration _pollInterval = Duration(seconds: 2);

  String? _messages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pHController.text = listAnalyse[0]['value'].toString();
    chloreController.text = listAnalyse[1]['value'].toString();
    tacController.text = listAnalyse[2]['value'].toString();
    stabilisantController.text = listAnalyse[3]['value'].toString();
    tempController.text = listAnalyse[4]['value'].toString();
    analyseChecked = null;
  }

  @override
  void dispose() {
    pHController.dispose();
    chloreController.dispose();
    tacController.dispose();
    stabilisantController.dispose();
    tempController.dispose();
    super.dispose();
  }

  _analyse() {
    Map<String, String>? valueAnalyse;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    if (buttonSelected[0]) {
      if (pHController.text.isEmpty ||
          chloreController.text.isEmpty ||
          tacController.text.isEmpty ||
          stabilisantController.text.isEmpty ||
          tempController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs')),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      valueAnalyse = {
        'ph': pHController.text,
        'chlore': chloreController.text,
        'tac': tacController.text,
        'stabilisant': stabilisantController.text,
        'temperature': tempController.text,
      };
    } else {
      if (imageBandelette == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez prendre une photo de votre bandelette'),
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }
    }

    print(valueAnalyse);

    TokenStorage.getToken().then((tokenValue) async {
      if (sessionId == null) {
        setState(() {
          sessionId = uuid.v4();
        });
      }

      var pool_id = await PoolIdStorage.getPoolId();

      AnalyseService()
          .sendAnalyse(
            tokenValue!,
            AnalyseModel(
              pool_id: int.tryParse(pool_id!),
              analyse: valueAnalyse,
              photo_bandelette_base64: imageBandelette,
            ),
          )
          .then((response) async {
            print(response);
            _isLoading = true;
            try {
              if (response['status'] == "pending") {
                print('En cours de traitement. Merci de patienter...');
              }

              final finalResponse = await _pollUntilCompleted(
                tokenValue,
                response['analyse_id'],
              );
              if (!mounted) return;

              print(finalResponse);
              setState(() {
                _displayOutput = true;
                outputAnalyse = finalResponse;
              });
            } catch (error) {
              if (!mounted) return;
              print('Temps d\'attente dépassé. Merci de réessayer. $error');
              setState(() {
                _displayOutput = true;
                outputAnalyse = 'Temps d\'attente dépassé. Merci de réessayer.';
              });
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
            setState(() {
              _isLoading = false;
            });
          });
    });
  }

  Future<String> _pollUntilCompleted(
    String token,
    String analyse_id,
  ) async {
    for (int attempt = 0; attempt < _pollMaxAttempts; attempt++) {
      final res = await AnalyseService().responseAnalyse(token, analyse_id);
      print(res);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse de l\'eau'),
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: screenWidth * 0.08,
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.25)),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModeButton(
                        label: 'Saisir les valeurs',
                        selected: buttonSelected[0],
                        onPressed: () {
                          setState(() {
                            buttonSelected[0] = true;
                            buttonSelected[1] = false;
                            analyseChecked = null;
                            _displayOutput = false;
                            imageBandelette = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildModeButton(
                        label: 'Photo bandelette',
                        selected: buttonSelected[1],
                        onPressed: () {
                          setState(() {
                            buttonSelected[0] = false;
                            buttonSelected[1] = true;
                            analyseChecked = null;
                            _displayOutput = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              buttonSelected[0]
                  ? Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Entrez les valeurs de votre analyse de l\'eau',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.separated(
                              itemCount: listAnalyse.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) =>
                                  _buildListAnalyse(listAnalyse[index]),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Prenez une photo de votre bandelette pour analyser votre eau',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 300,
                              minHeight: 200,
                              minWidth: double.infinity,
                            ),
                            child: Card.filled(
                              color: const Color(0xFF151515),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Colors.amber.withOpacity(0.25),
                                ),
                              ),
                              child: Center(
                                child: Stack(
                                  children: [
                                    if (imageBandelette != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.file(
                                          imageBandelette!,
                                          width: screenWidth / 2,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    Container(
                                      width: screenWidth / 2,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          PickImage pickImage = PickImage(
                                            onImagePicked: (file) {
                                              print(
                                                'Image picked: ${file.path}',
                                              );
                                              setState(() {
                                                imageBandelette = file;
                                              });
                                            },
                                            context: context,
                                          );
                                          pickImage.showImageSourceSheet();
                                        },
                                        icon: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 48,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

              const SizedBox(height: 20),
              _displayOutput
                  ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Résultat de l\'analyse',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.amber,
                            ),
                          ),
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                height: 2,
                                color: Colors.amber.withOpacity(0.25),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                top: -6,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 320,
                                top: -10,
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.copy),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 150),
                            child: SingleChildScrollView(
                              child: Text(
                                outputAnalyse,
                                textAlign: TextAlign.center, 
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,                   
                                  //fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              /* Clipboard.setData(ClipboardData(text: outputAnalyse));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Résultat copié dans le presse-papier')),
                      ); */
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('Continuer la conversation'),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
              const SizedBox(height: 16),
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
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: selected ? Colors.amber : Colors.transparent,
        foregroundColor: selected ? Colors.black : Colors.amber,
        side: BorderSide(
          color: selected ? Colors.amber : Colors.amber.withOpacity(0.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      child: Text(label, textAlign: TextAlign.center),
    );
  }

  Widget _buildListAnalyse(Map<String, String> analyse) {
    selectedAnalyse = analyseChecked == analyse;

    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.zero,

      child: ListTile(
        onTap: () {
          setState(() {
            analyseChecked = analyse;
            _displayOutput = false;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Icon(
          selectedAnalyse ? Icons.check_circle : Icons.water_drop_outlined,
          color: selectedAnalyse ? Colors.amber : Colors.white70,
          size: screenWidth * 0.03,
        ),
        title: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 30,
          children: [
            Text(
              '${analyse['name']} =',
              style: TextStyle(
                color: selectedAnalyse ? Colors.amber : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: screenWidth * 0.03,
              ),
            ),
            selectedAnalyse
                ? Expanded(
                    child: TextField(
                      controller: _controllerForAnalyseName(analyse['name']),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.amber.withOpacity(0.25),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                      ),
                      autofocus: selectedAnalyse,
                      onSubmitted: (value) {
                        selectedAnalyse = false;
                        //_displayOutput = false;
                        analyseChecked = null;
                      },
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  )
                : Expanded(
                    child: Text(
                      _controllerForAnalyseName(analyse['name']).text,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: selectedAnalyse ? Colors.amber : Colors.white70,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ),
            Text(
              analyse['unit']!,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: selectedAnalyse ? Colors.amber : Colors.white70,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: screenWidth * 0.03,
          color: selectedAnalyse ? Colors.amber : Colors.white54,
        ),
      ),
    );
  }

  TextEditingController _controllerForAnalyseName(String? analyseName) {
    return switch (analyseName) {
      'pH' => pHController,
      'Chlore' => chloreController,
      'TAC' => tacController,
      'Stabilisant' => stabilisantController,
      'Température' => tempController,
      _ => pHController,
    };
  }
}
