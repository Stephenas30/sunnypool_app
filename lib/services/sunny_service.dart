import 'dart:convert';

import 'package:sunnypool_app/models/message_model.dart';
import 'package:http/http.dart' as http;

class SunnyService {
  static const String baseUrl =
      "https://n8n.trouvezpourmoi.com/webhook-test/sunny";
      //"https://sunny.trouvezpourmoi.com/wp-json/sunny-pool/v1";

  Future<Map<String, dynamic>> sendChat(String token, MessageModel message) async {
    print(token);
    final response = await http.post(
      Uri.parse("$baseUrl/v2"),
      headers: {
        "Content-Type": "application/json",
        /* "Authorization": "Bearer $token", */
      },
      body: jsonEncode({
        "message": message.message,
        /* "image_base64": message.image_base64, */
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0];
    } else {
      throw Exception("Erreur de connexion : \\${response.body}");
    }
  }

  Future<Map<String, dynamic>> responseChat(String token, String conversationId) async {
    print(conversationId);
    final response = await http.get(
      Uri.parse("$baseUrl/chat/poll?conversation_id=$conversationId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Erreur de connexion : \\${response.body}");
    }
  }

}
