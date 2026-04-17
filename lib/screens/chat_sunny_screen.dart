import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/message_model.dart';
import 'package:sunnypool_app/screens/login_screen.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/services/sunny_service.dart';
import 'package:sunnypool_app/utils/poolId_storage.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class ChatSunnyScreen extends StatefulWidget {
  const ChatSunnyScreen({Key? key}) : super(key: key);

  @override
  State<ChatSunnyScreen> createState() => _ChatSunnyScreenState();
}

class _ChatSunnyScreenState extends State<ChatSunnyScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final uuid = Uuid();
  final ImagePicker _picker = ImagePicker();
  String? sessionId = null;
  int? thread_id = null;
  bool _isLoading = false;
  File? image_pool;

  String? tokenValue;

  static const _borderColor = Color(0x33FFD54F);

  static const int _pollMaxAttempts = 25;
  static const Duration _pollInterval = Duration(seconds: 2);

  List<dynamic> listConversation = [];

  Map<String, bool> optionSend = {
    'meteo': false,
    'historique': true,
    'produits': false,
    'alertes': true,
    'planning': true,
    'coordonnees': true,
  };

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);

    setState(() {
      image_pool = File(photo!.path);
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.amber),
                title: const Text(
                  'Sélectionner une photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.amber),
                title: const Text(
                  'Prendre une photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(String text) {
    if (text.isEmpty && image_pool == null) return;

    setState(() {
      _getAIResponse(text, image_pool);
      _messages.add({
        'role': 'user',
        'text': text,
        'image': image_pool?.path ?? '',
      });
      _isLoading = true;
      image_pool = null;
    });
    _controller.clear();
  }

  void _getAIResponse(String userMessage, File? image) {
    if (sessionId == null) {
      setState(() {
        sessionId = uuid.v4();
      });
    }
    print(sessionId);
    TokenStorage.getToken().then((token) {
      if (token == null || token.isEmpty) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'text': 'Session expirée. Veuillez vous reconnecter.',
          });
          _isLoading = false;
        });
        return;
      }
      /*       setState(() {
              _messages.add({'role': 'assistant', 'text': "Réponse en cours..."});
              _isLoading = false;
            }); */
      SunnyService()
          .sendChat(
            token,
            sessionId.toString(),
            MessageModel(
              message: userMessage,
              image: image?.path,
              data_options: optionSend,
            ),
            thread_id,
          )
          .then((response) async {
            /* final responseChat = (response['output'] ?? '').toString();
            if (responseChat.isEmpty) {
              setState(() {
                _messages[_messages.length - 1] = {
                  'role': 'assistant',
                  'text': 'Conversation invalide. Merci de réessayer.',
                };
                _isLoading = false;
              });
              return;
            }

            setState(() {
              _messages.add({'role': 'assistant', 'text': responseChat});
              _isLoading = false;
            }); */
            print(response);

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
                token,
                response['conversation_id'],
              );
              if (!mounted) return;

              setState(() {
                _messages[_messages.length - 1] = {
                  'role': 'assistant',
                  'text': finalResponse,
                };
                _isLoading = false;
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
            }
          })
          .catchError((error) {
            setState(() {
              _messages.add({
                'role': 'assistant',
                'text': 'Une erreur est survenue: $error',
              });
              _isLoading = false;
            });

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

  Future<void> _getAllConversation() async {
    tokenValue = await TokenStorage.getToken();
    String? poolId = await PoolIdStorage.getPoolId();
    Map<String, dynamic> response = await SunnyService().getAllConversation(
      tokenValue!,
      int.tryParse(poolId!)!,
    );
    setState(() {
      listConversation = response['data'];
      //print(listConversation);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllConversation();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final theme = Theme.of(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Sunny'),
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
      drawer: Drawer(
        backgroundColor: const Color(0xFF111111),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
                child: const Text(
                  'Menu Sunny',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.amber),
                title: const Text(
                  'Nouveau message',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => {
                  setState(() {
                    sessionId = null;
                    _messages.clear();
                  }),
                  Navigator.pop(context),
                },
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              listConversation.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune conversation disponible pour le moment.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      color: Colors.amber,
                      onRefresh: _getAllConversation,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.8,
                          //maxWidth: screenWidth * 0.4
                        ),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: listConversation.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _buildListConversation(listConversation[index]),
                        ),
                      ),
                    ),
              /* ListTile(
                leading: const Icon(Icons.person, color: Colors.amber),
                title: const Text('Profil', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileScreen()),
                  );
                },
              ), */
            ],
          ),
        ),
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
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.amber),
                  onPressed: () => {
                    _getAllConversation(),
                    scaffoldKey.currentState?.openDrawer()
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (msg['image'] != null && msg['image']!.isNotEmpty)
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(msg['image']!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: const BoxConstraints(maxWidth: 290),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.amber
                                : const Color(0xFF1D1D1D),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isUser ? Colors.amber : Colors.white24,
                            ),
                          ),
                          child: Text(
                            msg['text']!,
                            style: TextStyle(
                              color: isUser ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image_pool != null
                      ? Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(image_pool!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    image_pool = null;
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        //alignment: WrapAlignment.spaceBetween,
                        children: ['meteo', 'produits'].map((item) {
                          //final selected = optionSendChecked.contains(item);
                          return FilterChip(
                            label: Text(
                              item,
                              style: TextStyle(fontSize: screenWidth * 0.02),
                            ),
                            selected: optionSend[item]!,
                            selectedColor: Colors.amber,
                            checkmarkColor: Colors.black,
                            labelStyle: TextStyle(
                              color: optionSend[item]!
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            side: const BorderSide(color: _borderColor),
                            onSelected: (_) {
                              setState(() {
                                optionSend[item] = !optionSend[item]!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Tapez votre message...',
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white54,
                                  ),
                                  onPressed: _showImageSourceSheet,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.black),
                              onPressed: () => _sendMessage(_controller.text),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListConversation(Map<String, dynamic> conversation) {
    final theme = Theme.of(context);
    final title = conversation['title'];
    final threadId = conversation['id'];

    return /* Card(
      child: */ InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        setState(() {
          sessionId = threadId.toString();
          thread_id = threadId;
          _messages.clear();
          _isLoading = true;
        });
        Navigator.pop(context);
        dynamic message = await SunnyService().getConversation(
          tokenValue!,
          threadId,
        );
        List<dynamic> data = message['data'];
        List.generate(data.length, (index) {
          //print(data[index]);
          setState(() {
            _messages.add({'role': 'user', 'text': data[index]['message']});
            _messages.add({
              'role': 'assistant',
              'text': data[index]['response'],
            });
            _isLoading = false;
          });
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /* ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  pool.photoPool?.photoBassin ?? 'assets/piscine.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.pool, color: Colors.white54, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16), */
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.amber),
            ),

            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.amber),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
