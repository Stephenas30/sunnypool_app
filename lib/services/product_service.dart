import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sunnypool_app/models/product_model.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/utils/poolId_storage.dart';

class ProductService {
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

  Future<Map<String, dynamic>> getAllProducts(String token) async {
    String idPool = await PoolIdStorage.getPoolId() as String;
    final response = await http.get(
      Uri.parse("$baseUrl/pool/$idPool/products"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final errorData = jsonDecode(response.body);
      throw ApiException(statusCode: response.statusCode, data: errorData);
    }
  }

  Future<Map<String, dynamic>> addProduct(
    String token,
    ProductModel product,
  ) async {
    print(token);
    String idPool = await PoolIdStorage.getPoolId() as String;
    final photoFaceBase64 = await _toBase64IfFilePath(product.photoFace);
    final photoNoticeBase64 = await _toBase64IfFilePath(
      product.photoNoticeDosage,
    );
    final response = await http.post(
      Uri.parse("$baseUrl/pool/$idPool/products"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "nom_produit": product.name,
        "categorie": product.categorie.name,
        "marque": product.marque, 
        "commentaire": product.commentaire,
        "quantite": product.quantity,
        "unite": product.unit,
        "photo_face_base64": photoFaceBase64,
        "photo_notice_base64": photoNoticeBase64,
        "date_ajout": product.dateAjout,
        "date_mise_a_jour": product.dateMiseAJour,
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
