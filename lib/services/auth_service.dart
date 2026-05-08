import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sunnypool_app/services/internet_service.dart';

class AuthService {
  static const String baseUrl =
      "https://sunny.trouvezpourmoi.com/wp-json/api/v1";
  static const String wpBaseUrl = "https://sunny.trouvezpourmoi.com/wp-json/sunny-pool/v1";

  Future<String?> login(String username, String password) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }

    final response = await http.post(
      Uri.parse("$baseUrl/mo-jwt"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    //print("Réponse serveur: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["jwt_token"];
    } else {
      throw ("Nom d'utilisateur ou mot de passe incorrect");
    }
  }

  Future<String?> register(String username, String password) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }

    final response = await http.post(
      Uri.parse("$baseUrl/mo-jwt-register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "apikey": "gZUZCAquftTlOZXulEUCqnUcyJJshTGr",
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["jwt_token"];
    } else {
      throw Exception("Erreur de création : ${response.body}");
    }
  }

  Future<void> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }

    final response = await http.put(
      Uri.parse("$wpBaseUrl/user/password"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "current_password": currentPassword,
        "new_password": newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Erreur de création : ${response.body}");
    }
  }
}
