import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sunnypool_app/services/internet_service.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/utils/poolId_storage.dart';

class PlanningService {
  static const String baseUrl =
      "https://sunny.trouvezpourmoi.com/wp-json/sunny-pool/v1";

  Future<int?> _resolvePoolId([int? poolId]) async {
    if (poolId != null) return poolId;

    final stored = await PoolIdStorage.getPoolId();
    if (stored == null || stored.isEmpty) return null;

    return int.tryParse(stored);
  }

  Future<void> _ensureInternet() async {
    final hasInternet = await InternetService().hasInternet();
    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return dateTime.toIso8601String().replaceFirst('T', ' ').split('.').first;
  }

  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getAllPlanning(
    String token, {
    int? poolId,
  }) async {
    await _ensureInternet();

    final resolvedPoolId = await _resolvePoolId(poolId);
    final uri = resolvedPoolId != null
        ? Uri.parse("$baseUrl/planning?pool_id=$resolvedPoolId")
        : Uri.parse("$baseUrl/planning");

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = _decodeBody(response);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException(statusCode: response.statusCode, data: data);
  }

  Future<Map<String, dynamic>> getPlanning(String token, int planningId) async {
    await _ensureInternet();

    final response = await http.get(
      Uri.parse("$baseUrl/planning/$planningId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = _decodeBody(response);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException(statusCode: response.statusCode, data: data);
  }

  Future<Map<String, dynamic>> addPlanning(
    String token, {
    int? poolId,
    required String title,
    required DateTime startTime,
    DateTime? endTime,
    String? notes,
    bool isDone = false,
  }) async {
    await _ensureInternet();

    final resolvedPoolId = await _resolvePoolId(poolId);
    if (resolvedPoolId == null) {
      throw Exception("pool_id manquant pour créer un planning");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/planning"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "pool_id": resolvedPoolId,
        "title": title,
        "startTime": _formatDateTime(startTime),
        "endTime": endTime != null ? _formatDateTime(endTime) : null,
        "notes": notes ?? '',
        "isDone": isDone,
      }),
    );

    final data = _decodeBody(response);
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException(statusCode: response.statusCode, data: data);
  }

  Future<Map<String, dynamic>> updatePlanning(
    String token,
    int planningId, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    bool? isDone,
    bool clearEndTime = false,
  }) async {
    await _ensureInternet();

    final Map<String, dynamic> body = {};
    if (title != null) body["title"] = title;
    if (startTime != null) body["startTime"] = _formatDateTime(startTime);

    if (clearEndTime) {
      body["endTime"] = null;
    } else if (endTime != null) {
      body["endTime"] = _formatDateTime(endTime);
    }

    if (notes != null) body["notes"] = notes;
    if (isDone != null) body["isDone"] = isDone;

    final response = await http.put(
      Uri.parse("$baseUrl/planning/$planningId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    final data = _decodeBody(response);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException(statusCode: response.statusCode, data: data);
  }

  Future<Map<String, dynamic>> deletePlanning(
    String token,
    int planningId,
  ) async {
    await _ensureInternet();

    final response = await http.delete(
      Uri.parse("$baseUrl/planning/$planningId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = _decodeBody(response);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException(statusCode: response.statusCode, data: data);
  }
}
