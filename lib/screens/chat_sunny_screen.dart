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
        title: const Text(
          'Sunny',
          style: TextStyle(color: Colors.yellow),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.amber : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
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
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.amber),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}