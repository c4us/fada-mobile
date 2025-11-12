import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class UserService {
  //final String baseUrl = "http://192.168.1.179:8080/user";
  /// 🔹 Créer un utilisateur

  Future<bool> registerUser(String userPhone, String userPassword,String userProfile) async {
    final url = Uri.parse('$baseUrl/user');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "userPhone": userPhone.trim(),
      "userPassword": userPassword.trim(),
      "userProfile": userProfile,
      "userName" : userPhone.trim(),
      "userEmail" : userPhone.trim()
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Erreur backend: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erreur connexion: $e");
      return false;
    }
  }

  /// 🔹 Connexion utilisateur
  Future<Map<String, dynamic>?> loginUser(String identifier, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "identifier": identifier.trim(),
      "password": password.trim(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Erreur: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erreur connexion: $e");
      return null;
    }
  }
}
