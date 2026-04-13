import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sunnypool_app/models/pool_model.dart';

class ApiException implements Exception {
  final int statusCode;
  final dynamic data;

  ApiException({required this.statusCode, this.data});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, data: $data)';
}

class PoolService {
  static const String baseUrl =
      "https://sunny.trouvezpourmoi.com/wp-json/sunny-pool/v1";

  Future<Map<String, dynamic>> getAllPool(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/my-pools"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    //print("Réponse serveur: \\${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final errorData = jsonDecode(response.body);
      throw ApiException(statusCode: response.statusCode, data: errorData);
      //return jsonDecode(response.body);
    }
  }

  Future<Map<String, dynamic>> addPool(String token, Pool pool) async {
    print(token);
    final response = await http.post(
      Uri.parse("$baseUrl/pool"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name_piscine": pool.name,
        "type_piscine": pool.type.name,
        "longueur": pool.dimension.length,
        "largeur": pool.dimension.width,
        "profondeur": pool.dimension.depth,
        "adresse": pool.location.adresse,
        "code_postal": pool.location.codePostal,
        "ville": pool.location.ville,
        "pays": pool.location.pays,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      //throw Exception("Erreur de connexion : \\${response.body}");
      return jsonDecode(response.body);
    }
  }
}
