  
  import 'package:shared_preferences/shared_preferences.dart';
import '../models/livreur.dart';
import 'dart:convert';
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
}