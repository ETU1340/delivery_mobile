import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:delivery_app/services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/livreur.dart';
import 'dart:convert';
import 'livreur_service.dart';
class LocationService {
  final StreamController<Position> _locationController = StreamController<Position>.broadcast();
  Stream<Position> get locationStream => _locationController.stream;
  //final WebSocketService webSocketService = WebSocketService('wss://location.psad.hco.mg/');
  final SocketService socketService = SocketService('http://localhost:8080');
  Timer? _timer;

  final void Function(String message) onError;
  final void Function(String message) onSuccess;

  LocationService({required this.onError, required this.onSuccess}) {
    _startTracking();
  }

  void _startTracking() {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) async {
      try {
        bool serviceEnabled;
        LocationPermission permission;

        // Vérifie si les services de localisation sont activés
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          onError('Les services de localisation sont désactivés.');
          return;
        }

        // Vérifie les permissions de localisation
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            onError('Les permissions de localisation sont refusées.');
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          onError('Les permissions de localisation sont refusées de façon permanente.');
          return;
        }
        
        Livreur? livreur =   await LivreurService.getLivreurSession();


        // Si tout est correct, récupère la position actuelle
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        _locationController.add(position);
        _sendLocationToServer(position,livreur!.id);
        
        //onSuccess('Localisation envoyée avec succès.');
      } catch (e) {
        onError('Erreur lors de la récupération de la localisation: $e');
      }
    });
  }

  void _sendLocationToServer(Position position,String delivererId) {
    try {
      print('Localisation envoyée: ${position.latitude}, ${position.longitude}');
      socketService.sendLocation(position.latitude, position.longitude,delivererId);
    } catch (e) {
      onError('Erreur lors de l\'envoi de la localisation au serveur: $e');
    }
  }

  void dispose() {
    _timer?.cancel();
    _locationController.close();
  }
}
