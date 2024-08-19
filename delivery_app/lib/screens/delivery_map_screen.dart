// widgets/delivery_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:delivery_app/services/delivery_service.dart';
import 'package:delivery_app/models/delivery.dart';
import 'dart:async'; // Importez le package pour le Timer

class DeliveryMapScreen extends StatefulWidget {
  final String? deliveryId; // Ajoutez un paramètre pour l'identifiant de livraison

  DeliveryMapScreen({this.deliveryId}); // Modifiez le constructeur

  @override
  _DeliveryMapScreenState createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  final DeliveryService deliveryService = DeliveryService();
  LatLng? _currentPosition;

  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    // Appel initial pour obtenir la première position
    _getCurrentLocation();

    // Met à jour la position toutes les 30 secondes (ajustez selon les besoins)
    _locationTimer = Timer.periodic(Duration(seconds: 30), (Timer t) => _getCurrentLocation());
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Erreur lors de la récupération de la localisation : $e');
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel(); // Annuler le Timer lorsque le widget est détruit
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Delivery> deliveries = deliveryService.deliveries;

    // Filtrer les livraisons si un identifiant est fourni
    List<Delivery> deliveriesToShow = widget.deliveryId != null
        ? deliveries.where((delivery) => delivery.id == widget.deliveryId).toList()
        : deliveries;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carte des Livraisons'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: _currentPosition ?? LatLng(-18.8792, 47.5079), // Coordonnées par défaut si _currentPosition est null
          zoom: 12.0, // Zoom ajusté pour cadrer sur la ville
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              // Marqueur pour la position actuelle
              if (_currentPosition != null)
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: _currentPosition!,
                  builder: (ctx) => Icon(
                    Icons.my_location,
                    color: Colors.blue, // Couleur différente pour la position actuelle
                    size: 30.0,
                  ),
                ),
              // Marqueurs pour les livraisons
              ...deliveriesToShow.map((delivery) {
                return Marker(
                  width: 80.0,
                  height: 80.0,
                  point: delivery.position,
                  builder: (ctx) => Icon(
                    Icons.location_on,
                    color: delivery.status == 'En cours' ? Colors.green : Colors.red,
                    size: 40.0,
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
