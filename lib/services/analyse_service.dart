import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sunnypool_app/models/analyse_model.dart';
import 'package:sunnypool_app/services/internet_service.dart';

class AnalyseService {
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

  Future<Map<String, dynamic>> sendAnalyse(
    String token,
    //String sessionId,
    AnalyseModel analyse,
    /* [dynamic thread_id] */
  ) async {
    //print(thread_id);
    
      //thread_id ??= sessionId;
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }
  
    final photoBase64 = await _toBase64IfFilePath(analyse.photo_bandelette_base64?.path);

    final response = await http.post(
      Uri.parse("$baseUrl/analyse"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "pool_id": analyse.pool_id,
        "photo_bandelette_base64": photoBase64,
        "analyse": analyse.analyse,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Erreur de connexion : \\${response.body}");
    }
  }

  Future<Map<String, dynamic>> getAllAnalyse(
    String token,
    int poolId,
  ) async {

    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }

    final response = await http.get(
      Uri.parse("$baseUrl/analyse/history?pool_id=$poolId"),
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