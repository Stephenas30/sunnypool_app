import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sunnypool_app/utils/token_storage.dart';

class UserService {
  final String baseUrl = 'https://sunny.trouvezpourmoi.com/wp-json/sunny-pool/v1'; // Replace with your actual API base URL

  Future<Map<String, dynamic>> getUser(int id) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(Uri.parse('$baseUrl/me'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });
    //print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }

/*   Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user');
    }
  } */

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
}