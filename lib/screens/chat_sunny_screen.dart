import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/message_model.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';
import 'package:sunnypool_app/services/sunny_service.dart';
import 'package:sunnypool_app/utils/token_storage.dart';

class ChatSunnyScreen extends StatefulWidget {
  const ChatSunnyScreen({Key? key}) : super(key: key);

  @override
  State<ChatSunnyScreen> createState() => _ChatSunnyScreenState();
}

class _ChatSunnyScreenState extends State<ChatSunnyScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  static const int _pollMaxAttempts = 25;
  static const Duration _pollInterval = Duration(seconds: 2);

  void _sendMessage(String text) {
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });

    _controller.clear();
    _getAIResponse(text);
  }

  void _getAIResponse(String userMessage) {
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
          .sendChat(token, MessageModel(message: userMessage))
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                title: const Text('Nouveau message', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
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
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(maxWidth: 290),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.amber : const Color(0xFF1D1D1D),
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
              child: Row(
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
