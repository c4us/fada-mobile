import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final url = Uri.parse('$baseUrl/user/login');

    print('➡️ Envoi de la requête à $url');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    print('📥 Réponse brute : ${response.body}');
    print('🔢 Code HTTP : ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Afficher les clés du JSON pour debug
      print('🧩 Clés disponibles dans la réponse : ${data.keys}');

      // On essaie plusieurs structures possibles
      dynamic userId;
      if (data['id'] != null) {
        userId = data['id'];
      } else if (data['user'] != null && data['user']['id'] != null) {
        userId = data['user']['id'];
      } else if (data['users'] != null && data['users']['id'] != null) {
        userId = data['users']['id'];
      } else if (data['data'] != null && data['data']['id'] != null) {
        userId = data['data']['id'];
      }

      print('👤 ID utilisateur trouvé : $userId');

      if (userId == null) {
        throw Exception('⚠️ Impossible de trouver le champ "id" dans la réponse : $data');
      }

      // Sauvegarde dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId.toString());

      print('💾 ID utilisateur sauvegardé localement : $userId');

      return data;
    } else {
      throw Exception(
        '❌ Erreur de connexion : ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }
}
