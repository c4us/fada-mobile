import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ProductService {
  Future<List<dynamic>> getProductsByCategory(String categoryId) async {
    final url = Uri.parse('$baseUrl/product/category/$categoryId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body == null) return [];
      if (body is List) return body;
      if (body is Map) return [body]; // si ton backend renvoie un seul produit
      throw Exception("Format inattendu : ${body.runtimeType}");
    } else {
      throw Exception(
          'Erreur serveur : ${response.statusCode} ${response.reasonPhrase}');
    }
  }
}
