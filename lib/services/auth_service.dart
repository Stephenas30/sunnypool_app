import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://sunny.trouvezpourmoi.com/wp-json/api/v1";

  Future<String?> login(String username, String password) async {
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
      throw Exception("Erreur de connexion : ${response.body}");
    }
  }

  Future<String?> register(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/mo-jwt-register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "apikey": "gZUZCAquftTlOZXulEUCqnUcyJJshTGr"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["jwt_token"];
    } else {
      throw Exception("Erreur de création : ${response.body}");
    }
  }
}