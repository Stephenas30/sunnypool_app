import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sunnypool_app/models/product_model.dart';
import 'package:sunnypool_app/services/pool_service.dart';

class ProductService {
   static const String baseUrl =
      "https://sunny.trouvezpourmoi.com/wp-json/sunny-pool/v1";

  Future<Map<String, dynamic>> getAllProducts(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/pool/23434/products"),
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

  Future<Map<String, dynamic>> addProduct(String token, ProductModel product) async {
    print(token);
    final response = await http.post(
      Uri.parse("$baseUrl/pool/23434/products"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "nom_produit": product.name,
        "categorie": product.categorie.label,
        "marque": product.marque,
        "commentaire": product.commentaire,
        "quantite": product.quantity,
        "unite": product.unit,
        "photo_face": product.photoFace,
        "photo_notice": product.photoNoticeDosage,
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
