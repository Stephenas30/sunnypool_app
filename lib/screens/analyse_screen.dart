import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunnypool_app/models/message_model.dart';
import 'package:sunnypool_app/services/sunny_service.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
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

  String outputAnalyse = '';

  static const int _pollMaxAttempts = 25;
  static const Duration _pollInterval = Duration(seconds: 2);

  final List<Map<String, String>> _messages = [];

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
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    Map<String, String> valueAnalyse = {
      'ph': pHController.text,
      'chlore': chloreController.text,
      'tac': tacController.text,
      'stabilisant': stabilisantController.text,
      'temperature': tempController.text,
    };
    print(valueAnalyse);
    TokenStorage.getToken().then((tokenValue) {
      if (sessionId == null) {
        setState(() {
          sessionId = uuid.v4();
        });
      }
      SunnyService().sendChat(
        tokenValue!,
        sessionId!,
        MessageModel(
          message:
              "Analyser mon eau à partir de ses mesures (ph, chlore, tac, stabilisant, temperature)",
          analyse: valueAnalyse,
        ),
      ).then((response) async {
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
      }).catchError((onError){
        if (!mounted) return;
        print('Error $onError');
      }).whenComplete((){
        if (mounted) {
        setState(() {
          _isSubmitting = false;
          analyseChecked = null;
        });
      }
      });
    });
  }

  Future<String> _pollUntilCompleted(
    String token,
    String conversationId,
  ) async {
    for (int attempt = 0; attempt < _pollMaxAttempts; attempt++) {
      final res = await SunnyService().responseChat(token, conversationId);
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
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: listAnalyse.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _buildListAnalyse(listAnalyse[index]),
                ),
              ),
              const SizedBox(height: 20),
              outputAnalyse != '' ? Expanded(child: Container(
                child: Text(outputAnalyse, textAlign: TextAlign.center,),
              )): SizedBox.shrink(),
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
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () {
          setState(() {
            analyseChecked = analyse;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Icon(
          selectedAnalyse ? Icons.check_circle : Icons.water_drop_outlined,
          color: selectedAnalyse ? Colors.amber : Colors.white70,
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
              ),
            ),
            selectedAnalyse
                ? Expanded(
                    child: TextField(
                      controller: _controllerForAnalyseName(analyse['name']),
                      decoration: InputDecoration(),
                      autofocus: selectedAnalyse,
                      onSubmitted: (value) {
                        selectedAnalyse = false;
                      },
                    ),
                  )
                : Expanded(
                    child: Text(_controllerForAnalyseName(analyse['name']).text, textAlign: TextAlign.end),
                  ),
            Text(analyse['unit']!),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
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
