import 'dart:convert';

import 'package:sunnypool_app/models/dossier_model.dart';
import 'package:sunnypool_app/services/internet_service.dart';
import 'package:http/http.dart' as http;

class FolderThreadServicce {

  static const String baseUrl =
      "https://sunny.trouvezpourmoi.com/wp-json/sunny-pool/v1";

    Future<Map<String, dynamic>> getAllFolderThread(
    String token,
    int poolId,
  ) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }
    final response = await http.get(
      Uri.parse("$baseUrl/folders?pool_id=$poolId"),
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

   Future<Map<String, dynamic>> getAllThreadToFolder(
    String token,
    int folderId,
  ) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }
    final response = await http.get(
      Uri.parse("$baseUrl/threads/folder?folder_id=$folderId"),
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

  Future<Map<String, dynamic>> addThreadToFolder(
    String token,
    int folderId,
    int threadId
  ) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }
    final response = await http.put(
      Uri.parse("$baseUrl/folder/$folderId/thread/$threadId"),
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

  Future<Map<String, dynamic>> createFolder(
    String token,
    String pool_id,
    DossierModel folder,
  ) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }
    final response = await http.post(
      Uri.parse("$baseUrl/folder"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "pool_id": pool_id,
        "name": folder.name
      })
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Erreur de connexion : \\${response.body}");
    }
  }

  /* Future<Map<String, dynamic>> getFolderThread(
    String token,
    int folderId,
  ) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }
    final response = await http.get(
      Uri.parse("$baseUrl/chat/threads/$folderId/messages"),
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
  } */

  Future<Map<String, dynamic>> renameFolder(
    String token,
    int folderId,
    String newName,
  ) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }
    final response = await http.put(
      Uri.parse("$baseUrl/chat/threads/$folderId/rename"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "title": newName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Erreur de connexion : \\${response.body}");
    }
  }

/*   Future<Map<String, dynamic>> favoriteConversation(
    String token,
    int threadId,
    bool favorite,
  ) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }
    final response = await http.put(
      Uri.parse("$baseUrl/chat/threads/$threadId/favorite"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "favorites": favorite,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Erreur de connexion : \\${response.body}");
    }
  } */

  Future<Map<String, dynamic>> deleteFolder(
    String token,
    int folderId,
  ) async {
    final hasInternet = await InternetService().hasInternet();

    if (!hasInternet) {
      throw ('Aucune connexion Internet');
    }
    final response = await http.delete(
      Uri.parse("$baseUrl/chat/threads/$folderId"),
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