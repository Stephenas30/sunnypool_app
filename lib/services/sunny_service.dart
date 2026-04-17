import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sunnypool_app/models/message_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/* Future<XFile?> compressImage(String path) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    path,
    path + "_compressed.jpg",
    quality: 70, // 🔥 équilibre perf/qualité
  );
  if (result != null) {
    return XFile(result.path);
  }
  return null;
} */

class SunnyService {
  static const String baseUrl =
      "https://sunny.trouvezpourmoi.com/wp-json/sunny-pool/v1";

  Future<String?> _toBase64IfFilePath(String? value) async {
    if (value == null || value.isEmpty) return null;

    final file = File(value);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    }

    return value;
  }

  Future<Map<String, dynamic>> sendChat(
    String token,
    String sessionId,
    MessageModel message,
    [dynamic thread_id]
  ) async {
    print(thread_id);
    
      thread_id ??= sessionId;
  
    final photoBase64 = await _toBase64IfFilePath(message.image);

    final response = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "message": message.message,
        "image_base64": photoBase64,
        "conversation_id": sessionId,
        "data_options": message.data_options,
        "analyse": message.analyse,
        "thread_id": thread_id
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Erreur de connexion : \\${response.body}");
    }

    /* var uri = Uri.parse("$baseUrl/v2");

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
    } */
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

Future<Map<String, dynamic>> getAllConversation(
    String token,
    int poolId,
  ) async {

    final response = await http.get(
      Uri.parse("$baseUrl/chat/threads?pool_id=$poolId"),
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

  Future<Map<String, dynamic>> getConversation(
    String token,
    int threadId,
  ) async {

    final response = await http.get(
      Uri.parse("$baseUrl/chat/threads/$threadId/messages"),
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
