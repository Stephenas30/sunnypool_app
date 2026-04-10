import 'dart:convert';
import 'dart:io';

import 'package:sunnypool_app/models/message_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SunnyService {
  static const String baseUrl = "https://n8n.trouvezpourmoi.com/webhook/sunny";
  //"https://sunny.trouvezpourmoi.com/wp-json/sunny-pool/v1";

  Future<Map<String, dynamic>> sendChat(
    String sessionId,
    MessageModel message,
  ) async {
    print(sessionId);
    var uri = Uri.parse("$baseUrl/v2");

    var request = http.MultipartRequest('POST', uri);

    request.fields['message'] = message.message;

    if (message.image != null && message.image!.isNotEmpty) {
        request.files.add(
        await http.MultipartFile.fromPath('file', message.image ?? ''),
      );
      }

    // 🔸 Envoi
    var streamedResponse = await request.send();

    // 🔸 Convertir en réponse classique
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0];
    } else {
      throw Exception("Erreur de connexion : \\${response.body}");
    }
  }

  Future<Map<String, dynamic>> responseChat(
    String token,
    String conversationId,
  ) async {
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
