// models/delivery.dart
import 'package:latlong2/latlong.dart';

class Delivery {
  final String id;
  final String title;
  final LatLng position;
  final String status;
  final DateTime dateTime;  // Date et heure de la livraison

  Delivery({
    required this.id,
    required this.title,
    required this.position,
    required this.status,
    required this.dateTime,
  });
}