import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sunnypool_app/models/message_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<XFile?> compressImage(String path) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    path,
    path + "_compressed.jpg",
    quality: 70, // 🔥 équilibre perf/qualité
  );
  if (result != null) {
    return XFile(result.path);
  }
  return null;
}

class SunnyService {
  static const String baseUrl = "https://n8n.trouvezpourmoi.com/webhook-test/sunny";
  //"https://sunny.trouvezpourmoi.com/wp-json/sunny-pool/v1";

  Future<Map<String, dynamic>> sendChat(
    String sessionId,
    MessageModel message,
  ) async {
    print(sessionId);
    var uri = Uri.parse("$baseUrl/v2");

    late http.Response response;

    final hasImage = message.image != null;

    if (hasImage) {
      final request = http.MultipartRequest('POST', uri)
        ..fields['sessionId'] = sessionId
        ..fields['message'] = message.message;

      final compressed = await compressImage(message.image!);

      request.files.add(
        await http.MultipartFile.fromPath('file', compressed!.path),
      );

      final streamedResponse = await request.send().timeout(Duration(seconds: 20));
      response = await http.Response.fromStream(streamedResponse);
    } else {
      response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sessionId': sessionId,
          'message': message.message,
        }),
      );
    }

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
