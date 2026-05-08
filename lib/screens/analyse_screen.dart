import 'dart:async';
import 'dart:convert';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'chat_sunny_screen.dart';
import 'profile_screen.dart';

class AnalyseScreen extends StatefulWidget {
  const AnalyseScreen({super.key});

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
  String? sessionId;
  final uuid = Uuid();
  bool _isSubmitting = false;
  bool _isLoading = false;
  bool selectedAnalyse = false;

  File? imageBandelette;

  bool _displayOutput = false;
  String outputAnalyse = '';
  Map<String, dynamic>? _structuredOutput;
  bool _isResultModalOpen = false;

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

  List<dynamic> _asList(dynamic input) => input is List ? input : const [];

  Map<String, dynamic>? _normalizeAnalysePayload(dynamic value) {
    dynamic payload = value;
    if (payload == null) return null;

    if (payload is String) {
      final trimmed = payload.trim();
      if (trimmed.isEmpty) return null;
      final looksLikeJson =
          (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'));
      if (!looksLikeJson) return null;
      try {
        payload = jsonDecode(trimmed);
      } catch (_) {
        return null;
      }
    }

    if (payload is! Map) return null;

    final map = Map<String, dynamic>.from(payload);
    final hasExpectedKeys =
        map.containsKey('message') ||
        map.containsKey('water_analysis') ||
        map.containsKey('diagnosis') ||
        map.containsKey('actions') ||
        map.containsKey('products') ||
        map.containsKey('links') ||
        map.containsKey('warnings');

    return hasExpectedKeys ? map : null;
  }

  void _applyAnalysisOutput(dynamic response) {
    final structured = _normalizeAnalysePayload(response);
    final fallback = response?.toString() ?? '';
    setState(() {
      _displayOutput = true;
      _structuredOutput = structured;
      outputAnalyse = structured == null
          ? fallback
          : ((structured['message'] ?? '').toString().trim().isNotEmpty
                ? (structured['message'] ?? '').toString()
                : const JsonEncoder.withIndent('  ').convert(structured));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showResultModal();
    });
  }

  String _resultTextToCopy() {
    return _structuredOutput == null
        ? outputAnalyse
        : const JsonEncoder.withIndent('  ').convert(_structuredOutput);
  }

  void _copyResultToClipboard() {
    Clipboard.setData(ClipboardData(text: _resultTextToCopy()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Résultat copié dans le presse-papier')),
    );
  }

  String _buildSunnyPromptFromAnalysis() {
    final result = _resultTextToCopy().trim();
    return 'Voici le résultat de mon analyse de l\'eau :\n\n$result\n\nPeux-tu m\'aider à interpréter ce résultat et me proposer les prochaines actions ?';
  }

  void _continueConversationFromResult(BuildContext modalContext) {
    final result = _resultTextToCopy().trim();
    if (result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun résultat à envoyer au chat.')),
      );
      return;
    }

    Navigator.of(modalContext).pop();
    Future.microtask(() {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatSunnyScreen(
            initialMessage: _buildSunnyPromptFromAnalysis(),
            autoSendInitialMessage: true,
          ),
        ),
      );
    });
  }

  Future<void> _showResultModal() async {
    if (!_displayOutput || _isResultModalOpen || !mounted) return;
    _isResultModalOpen = true;

    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (modalContext) {
          final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 12),
              child: Container(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.amber.withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 6, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Résultat de l\'analyse',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.amber,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _copyResultToClipboard,
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copier le résultat',
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(modalContext).pop(),
                            icon: const Icon(Icons.close),
                            tooltip: 'Fermer',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 2,
                        color: Colors.amber.withOpacity(0.25),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: SingleChildScrollView(
                          child: _structuredOutput != null
                              ? _buildStructuredOutput(_structuredOutput!)
                              : Text(
                                  outputAnalyse,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _continueConversationFromResult(modalContext),
                          icon: const Icon(Icons.chat),
                          label: const Text('Continuer la conversation'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } finally {
      _isResultModalOpen = false;
    }

    if (!mounted) return;
    setState(() {
      _displayOutput = false;
    });
  }

  String _safePriority(dynamic value) {
    final key = (value ?? '').toString().toLowerCase();
    if (key == 'high' || key == 'medium' || key == 'low' || key == 'critical') {
      return key;
    }
    return 'low';
  }

  Color _priorityColor(dynamic value) {
    switch (_safePriority(value)) {
      case 'critical':
        return const Color(0xFFFF4D4D);
      case 'high':
        return const Color(0xFFFF7B7B);
      case 'medium':
        return const Color(0xFFFFB86B);
      default:
        return const Color(0xFFE6C96E);
    }
  }

  String _priorityLabel(dynamic value) {
    switch (_safePriority(value)) {
      case 'critical':
        return 'Critique';
      case 'high':
        return 'Élevée';
      case 'medium':
        return 'Moyenne';
      default:
        return 'Faible';
    }
  }

  Future<void> _openLink(String? rawUrl) async {
    final value = (rawUrl ?? '').trim();
    final uri = Uri.tryParse(value);
    final isHttp =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (!isHttp) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final launched = await launchUrl(
      uri!,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir ce lien'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildBadge(dynamic level, {String? prefix}) {
    final color = _priorityColor(level);
    final label = _priorityLabel(level);
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        border: Border.all(color: color.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${prefix != null ? '$prefix: ' : ''}$label',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _valueWithUnit(dynamic value, dynamic unit) {
    final v = (value ?? '').toString();
    final u = (unit ?? '').toString();
    if (u.trim().isEmpty) return v;
    return '$v $u';
  }

  Widget _buildStructuredOutput(Map<String, dynamic> payload) {
    final content = <Widget>[];
    final message = (payload['message'] ?? '').toString();
    final water = _asList(payload['water_analysis']);
    final diagnosis = payload['diagnosis'];
    final actions = _asList(payload['actions']);
    final products = _asList(payload['products']);
    final links = _asList(payload['links']);
    final warnings = _asList(payload['warnings']);

    if (message.trim().isNotEmpty) {
      content.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    if (water.isNotEmpty) {
      content.add(
        _buildSection(
          'Analyse de l\'eau',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: water.map((item) {
              if (item is! Map) return const SizedBox.shrink();
              final m = Map<String, dynamic>.from(item);
              final lineTitle =
                  '${(m['emoji'] ?? '').toString()} ${(m['parameter'] ?? 'Paramètre').toString()} : ${_valueWithUnit(m['value'], m['unit'])}'
                      .trim();
              final explanation = (m['explanation'] ?? '').toString();
              final badgeText = (m['label'] ?? '').toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lineTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (badgeText.isNotEmpty)
                          _buildBadge(m['status'], prefix: badgeText),
                      ],
                    ),
                    if (explanation.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          explanation,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (diagnosis is Map &&
        ((diagnosis['summary'] ?? '').toString().isNotEmpty ||
            (diagnosis['severity'] ?? '').toString().isNotEmpty)) {
      content.add(
        _buildSection(
          'Diagnostic',
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  (diagnosis['summary'] ?? 'Diagnostic disponible').toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if ((diagnosis['severity'] ?? '').toString().isNotEmpty)
                _buildBadge(diagnosis['severity'], prefix: 'Niveau'),
            ],
          ),
        ),
      );
    }

    if (actions.isNotEmpty) {
      content.add(
        _buildSection(
          'Actions',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: actions.map((item) {
              if (item is! Map) return const SizedBox.shrink();
              final m = Map<String, dynamic>.from(item);
              final title = (m['title'] ?? 'Action').toString();
              final description = (m['description'] ?? '').toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.white)),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if ((m['priority'] ?? '').toString().isNotEmpty)
                          _buildBadge(m['priority']),
                      ],
                    ),
                    if (description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          description,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (products.isNotEmpty) {
      content.add(
        _buildSection(
          'Produits conseillés',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: products.map((item) {
              if (item is! Map) return const SizedBox.shrink();
              final m = Map<String, dynamic>.from(item);
              final name = (m['name'] ?? 'Produit').toString();
              final reason = (m['reason'] ?? '').toString();
              final dosage = m['dosage'];
              final detail = <String>[];
              if (reason.isNotEmpty) detail.add(reason);
              if (dosage != null && dosage.toString().trim().isNotEmpty) {
                detail.add('Dosage: ${dosage.toString()}');
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• $name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (detail.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          detail.join(' • '),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (links.isNotEmpty) {
      content.add(
        _buildSection(
          'Liens utiles',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: links.map((item) {
              if (item is! Map) return const SizedBox.shrink();
              final m = Map<String, dynamic>.from(item);
              final title = (m['title'] ?? 'Ouvrir le lien').toString();
              final url = (m['url'] ?? '').toString();
              if (url.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x66FFD54F)),
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0x14FFD54F),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFF5D56D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _openLink(url),
                        child: Text(
                          url,
                          style: const TextStyle(
                            color: Colors.lightBlueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (warnings.isNotEmpty) {
      content.add(
        _buildSection(
          'Avertissements',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: warnings.map((item) {
              final text = item.toString();
              if (text.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $text',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.isEmpty
          ? [
              Text(
                payload.toString(),
                style: const TextStyle(color: Colors.white70),
              ),
            ]
          : content,
    );
  }

  void _analyse() {
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

      TokenStorage.getToken().then((tokenValue) async {
        if (sessionId == null) {
          setState(() {
            sessionId = uuid.v4();
          });
        }

        var poolId = await PoolIdStorage.getPoolId();

        AnalyseService()
            .sendAnalyse(
              tokenValue!,
              AnalyseModel(
                pool_id: int.tryParse(poolId!),
                analyse: valueAnalyse,
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
                _applyAnalysisOutput(finalResponse);
              } catch (error) {
                if (!mounted) return;
                print('Temps d\'attente dépassé. Merci de réessayer. $error');
                _applyAnalysisOutput(
                  'Temps d\'attente dépassé. Merci de réessayer.',
                );
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

      TokenStorage.getToken().then((tokenValue) async {
        if (sessionId == null) {
          setState(() {
            sessionId = uuid.v4();
          });
        }

        var poolId = await PoolIdStorage.getPoolId();

        AnalyseService()
            .sendAnalysePhoto(
              tokenValue!,
              AnalyseModel(
                pool_id: int.tryParse(poolId!),
                photo_bandelette_base64: imageBandelette,
                type: 'test_strip',
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
                _applyAnalysisOutput(finalResponse);
              } catch (error) {
                if (!mounted) return;
                print('Temps d\'attente dépassé. Merci de réessayer. $error');
                _applyAnalysisOutput(
                  'Temps d\'attente dépassé. Merci de réessayer.',
                );
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

    print(valueAnalyse);
  }

  Future<dynamic> _pollUntilCompleted(String token, String analyseId) async {
    for (int attempt = 0; attempt < _pollMaxAttempts; attempt++) {
      final res = await AnalyseService().responseAnalyse(token, analyseId);
      print(res);
      final found = res['found'] == true;

      if (found) {
        final response = res['response'];
        if (response != null && response.toString().trim().isNotEmpty) {
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
                            _structuredOutput = null;
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
                            _structuredOutput = null;
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
                              separatorBuilder: (_, _) =>
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
    final iconSize = (screenWidth * 0.03).clamp(14.0, 18.0);
    final textSize = (screenWidth * 0.034).clamp(12.0, 16.0);

    return Card(
      margin: EdgeInsets.zero,

      child: ListTile(
        onTap: () {
          setState(() {
            analyseChecked = analyse;
            _displayOutput = false;
            _structuredOutput = null;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Icon(
          selectedAnalyse ? Icons.check_circle : Icons.water_drop_outlined,
          color: selectedAnalyse ? Colors.amber : Colors.white70,
          size: iconSize,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${analyse['name']} =',
              style: TextStyle(
                color: selectedAnalyse ? Colors.amber : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: textSize,
              ),
            ),
            const SizedBox(width: 14),
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
                      style: TextStyle(color: Colors.amber, fontSize: textSize),
                    ),
                  )
                : Expanded(
                    child: Text(
                      _controllerForAnalyseName(analyse['name']).text,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: selectedAnalyse ? Colors.amber : Colors.white70,
                        fontSize: textSize,
                      ),
                    ),
                  ),
            Text(
              analyse['unit']!,
              style: TextStyle(
                fontSize: textSize,
                color: selectedAnalyse ? Colors.amber : Colors.white70,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: iconSize,
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
