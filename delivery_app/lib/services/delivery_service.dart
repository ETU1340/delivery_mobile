// services/delivery_service.dart
import '../models/delivery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_urls.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'livreur_service.dart';
import '../models/livreur.dart';
class DeliveryService {
  static Future<List<Delivery>> getDeliveries() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  Livreur? livreur =   await LivreurService.getLivreurSession();
  try {
    final response = await http.get(
      Uri.parse(ApiUrls.deliveries+'/livreur/'+livreur!.id),
      headers: {'x-auth-token': '$token'},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
  
      print("response");
      print(response.body);
      return jsonResponse.map((delivery) => Delivery.fromJson(delivery)).toList();
    } else {
      print('Failed to load deliveries with status code: ${response.statusCode}');
      throw Exception('Failed to load deliveries with status code: ${response.statusCode}');
    }
  } catch (error) {
    print('An error occurred: $error');
    throw Exception('An error occurred while fetching deliveries: $error');
  }
}


  static Future<List<Delivery>> getDeliveriesNow() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  Livreur? livreur =   await LivreurService.getLivreurSession();
  try {
    final response = await http.get(
      Uri.parse(ApiUrls.deliveries+'/now/'+livreur!.id),
      headers: {'x-auth-token': '$token'},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
          print(token);
      print("response");
      print(response.body);
      return jsonResponse.map((delivery) => Delivery.fromJson(delivery)).toList();
    } else {
      print('Failed to load deliveries with status code: ${response.statusCode}');
      throw Exception('Failed to load deliveries with status code: ${response.statusCode}');
    }
  } catch (error) {
    print('An error occurred: $error');
    throw Exception('An error occurred while fetching deliveries: $error');
  }
}

   static Future<void> updateDeliveryStatus(String deliveryId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final url = Uri.parse(ApiUrls.deliveries+'/'+deliveryId);

    try {
      final response = await http.put(
        url,
        headers: {'x-auth-token': '$token','Content-Type': 'application/json',},
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        // Statut mis à jour avec succès
        print('Statut de la livraison mis à jour avec succès');
      } else {
        // Erreur lors de la mise à jour du statut
        throw Exception('Failed to update delivery status');
      }
    } catch (e) {
      // Gestion des erreurs
      throw Exception('Erreur lors de la mise à jour du statut de la livraison: $e');
    }
  }



}
