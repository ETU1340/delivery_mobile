import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart'; // Importation confirmée
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:delivery_app/services/delivery_service.dart';
import 'package:delivery_app/models/delivery.dart';
import 'dart:async';

class DeliveryMapScreen extends StatefulWidget {
  final String? deliveryId;

  DeliveryMapScreen({this.deliveryId});

  @override
  _DeliveryMapScreenState createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  final DeliveryService deliveryService = DeliveryService();
  LatLng? _currentPosition;
  List<Delivery> _deliveries = [];
  Timer? _locationTimer;
  final PopupController _popupController = PopupController(); // Contrôleur de popup

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _loadDeliveries();
  }

  void _startLocationUpdates() {
    _getCurrentLocation();
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

  Future<void> _loadDeliveries() async {
    try {
      final deliveries = await DeliveryService.getDeliveriesNow();
      setState(() {
        _deliveries = deliveries;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des livraisons')),
      );
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Delivery> deliveriesToShow = widget.deliveryId != null
        ? _deliveries.where((delivery) => delivery.id == widget.deliveryId).toList()
        : _deliveries;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carte des Livraisons'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: _currentPosition ?? LatLng(-18.8792, 47.5079),
              zoom: 13.0,
              onTap: (_, __) => _popupController.hideAllPopups(), // Masquer les popups au clic en dehors
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition!,
                      builder: (ctx) => Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 25.0,
                      ),
                    ),
                  ...deliveriesToShow.map((delivery) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(delivery.deliveryAddress.latitude, delivery.deliveryAddress.longitude),
                      builder: (ctx) => Icon(
                        Icons.person_pin_circle,
                        color: Colors.red,
                        size: 25.0,
                      ),
                    );
                  }).toList(),
                ],
              ),
              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                  popupController: _popupController,
                  markers: deliveriesToShow.map((delivery) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(delivery.deliveryAddress.latitude, delivery.deliveryAddress.longitude),
                      builder: (ctx) => Icon(
                        Icons.person_pin_circle,
                        color: Colors.red,
                        size: 25.0,
                      ),
                    );
                  }).toList(),
                    popupDisplayOptions: PopupDisplayOptions(
                    builder: (BuildContext context, Marker marker) {
                    final delivery = deliveriesToShow.firstWhere(
                        (delivery) =>
                            LatLng(delivery.deliveryAddress.latitude, delivery.deliveryAddress.longitude) ==
                            marker.point);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Livraison/${delivery.id}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Client: ${delivery.clientName}'),
                            Text('Télephone: ${delivery.clientSurname}'),
                          ],
                        ),
                      ),
                    );
                  }
                ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.my_location, color: Colors.blue, size: 20.0),
                      SizedBox(width: 4.0),
                      Text('Position Actuelle'),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(Icons.person_pin_circle, color: Colors.red, size: 20.0),
                      SizedBox(width: 4.0),
                      Text('Livraison'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
