import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/message_model.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';
import 'package:sunnypool_app/services/sunny_service.dart';
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
  bool _isLoading = false;
  File? image_pool;

  static const int _pollMaxAttempts = 25;
  static const Duration _pollInterval = Duration(seconds: 2);

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
      SunnyService()
          .sendChat(
            sessionId!,
            MessageModel(message: userMessage, image: image?.path),
          )
          .then((response) async {
            final responseChat = (response['output'] ?? '').toString();
            if (responseChat.isEmpty) {
              setState(() {
                _messages.add({
                  'role': 'assistant',
                  'text': 'Conversation invalide. Merci de réessayer.',
                });
                _isLoading = false;
              });
              return;
            }

            setState(() {
              _messages.add({'role': 'assistant', 'text': responseChat});
              _isLoading = false;
            });

            /* try {
              final finalResponse = await _pollUntilCompleted(token, conversationId);
              if (!mounted) return;

              
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
            } */
          })
          .catchError((error) {
            setState(() {
              _messages.add({
                'role': 'assistant',
                'text': 'Une erreur est survenue: $error',
              });
              _isLoading = false;
            });
          });
    });
  }

  /* Future<String> _pollUntilCompleted(String token, String conversationId) async {
    for (int attempt = 0; attempt < _pollMaxAttempts; attempt++) {
      final res = await SunnyService().responseChat(token, conversationId);
      //final found = res['found'] == true;

      //if (found) {
        final response = (res[0]['response'] ?? '').toString().trim();
        if (response.isNotEmpty) {
          return response;
        }
      //}

      await Future.delayed(_pollInterval);
    }

    throw TimeoutException('Polling timeout');
  } */

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Tapez votre message...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF1A1A1A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Colors.amber),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Colors.amber),
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
            ),
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
