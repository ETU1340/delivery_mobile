  
 import 'package:shared_preferences/shared_preferences.dart';
import '../models/livreur.dart';
import 'dart:convert';
import '../utils/api_urls.dart';
import 'package:http/http.dart' as http;
class LivreurService {
  
  static Future<Livreur?> getLivreurSession() async {
   final prefs = await SharedPreferences.getInstance();
    final livreurJson = prefs.getString('livreur');
    if (livreurJson != null) {
      final Map<String, dynamic> livreurMap = jsonDecode(livreurJson);
      return Livreur.fromJson(livreurMap);
    }
    return null;

  }


  
  // Fonction pour récupérer le livreur par rapport à l'ID connecté via un appel API
  static Future<Livreur?> getLivreurById(String id) async {
    try {
      // Remplacez l'URL par celle de votre API
      final url = Uri.parse(ApiUrls.livreurs+"/"+id);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'x-auth-token': '$token', // Ajoutez un token d'autorisation si nécessaire
        },
      );

      if (response.statusCode == 200) {
        // Si la réponse est bonne, convertir le JSON en objet Livreur
        final Map<String, dynamic> livreurMap = jsonDecode(response.body);
        return Livreur.fromJson(livreurMap);
      } else {
        // Gestion des erreurs
        print('Erreur lors de la récupération du livreur: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur: $e');
      return null;
    }
  }
}