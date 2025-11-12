import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class StructureService {
  /// 🔹 Récupère toutes les structures depuis le backend
  Future<List<dynamic>> getAllStructures() async {
    final url = Uri.parse('$baseUrl/structure');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Erreur serveur : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }

  /// 🔹 Création d’une structure
  ///
  /// Retourne l’ID de la structure créée (pour lier ensuite la photo).
  Future<String?> createStructure(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/structure'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      print('✅ Structure créée : $decoded');
      return decoded['idStructure']?.toString() ??
          decoded['id']?.toString(); // sécurité selon le backend
    } else {
      print('❌ Erreur backend : ${response.body}');
      throw Exception("Erreur backend : ${response.body}");
    }
  }

  /// 🔹 Upload de photo de structure (PUT /structure/photo)
  ///
  /// Envoie le fichier image et l’ID de la structure au backend Spring Boot.
  Future<String> uploadStructurePhoto(String idStructure, File imageFile) async {
    final url = Uri.parse("$baseUrl/structure/photo");

    final request = http.MultipartRequest('PUT', url)
      ..fields['id'] = idStructure
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    print('📤 Upload photo => Structure ID: $idStructure, Path: ${imageFile.path}');

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      print('✅ Photo envoyée avec succès : $respStr');
      return respStr;
    } else {
      final error = await response.stream.bytesToString();
      print('❌ Erreur upload (${response.statusCode}) : $error');
      throw Exception("Erreur upload photo : $error");
    }
  }
}
