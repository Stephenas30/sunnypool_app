import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';

class ChatSunnyScreen extends StatefulWidget {
  const ChatSunnyScreen({Key? key}) : super(key: key);

  @override
  State<ChatSunnyScreen> createState() => _ChatSunnyScreenState();
}

class _ChatSunnyScreenState extends State<ChatSunnyScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final Map<String, String> _responses = {
    'bonjour': 'Bonjour! Je suis Sunny, votre assistant IA. Comment puis-je vous aider?',
    'aide': 'Je peux vous assister avec vos questions. Posez-moi n\'importe quoi!',
    'weather': 'Je peux vous donner des informations météorologiques. Quelle ville vous intéresse?',
    'merci': 'De rien! Y a-t-il autre chose que je puisse faire pour vous?',
  };

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
    Future.delayed(const Duration(milliseconds: 500), () {
      String response = _responses[userMessage.toLowerCase()] ??
          'Je n\'ai pas compris. Pouvez-vous reformuler votre question?';

      setState(() {
        _messages.add({'role': 'assistant', 'text': response});
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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