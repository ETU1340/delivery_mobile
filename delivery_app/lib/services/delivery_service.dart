// services/delivery_service.dart
import '../models/delivery.dart';
import 'package:latlong2/latlong.dart';

class DeliveryService {
  List<Delivery> get deliveries => [
    Delivery(
      id: '1',
      title: 'Livraison 1',
      position: LatLng(-18.8792 + 0.01, 47.5079 + 0.01),  // Position légèrement modifiée
      status: 'En cours',
      dateTime: DateTime(2024, 8, 17, 9, 30),  // Date et heure spécifiques
    ),
    Delivery(
      id: '2',
      title: 'Livraison 2',
      position: LatLng(-18.8792 + 0.02, 47.5079 - 0.02),  // Position légèrement modifiée
      status: 'Planifiée',
      dateTime: DateTime(2024, 8, 17, 14, 00),  // Date et heure spécifiques
    ),
    Delivery(
      id: '3',
      title: 'Livraison 3',
      position: LatLng(-18.8792 - 0.01, 47.5079 + 0.03),  // Position légèrement modifiée
      status: 'Planifiée',
      dateTime: DateTime(2024, 8, 20, 14, 00),  // Date et heure spécifiques
    ),
    Delivery(
      id: '4',
      title: 'Livraison 4',
      position: LatLng(-18.8792 - 0.03, 47.5079 - 0.01),  // Position légèrement modifiée
      status: 'En cours',
      dateTime: DateTime(2024, 8, 20, 16, 00),  // Date et heure spécifiques
    ),
    Delivery(
      id: '5',
      title: 'Livraison 5',
      position: LatLng(-18.8792 + 0.015, 47.5079 - 0.025),  // Position légèrement modifiée
      status: 'Planifiée',
      dateTime: DateTime(2024, 8, 21, 10, 00),  // Date et heure spécifiques
    ),
    // Ajoutez d'autres livraisons ici avec des positions variées mais dans les limites d'Antananarivo
  ];
}
