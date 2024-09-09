import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:delivery_app/services/socket_service.dart';
import 'package:delivery_app/services/location_service.dart';
import 'package:delivery_app/models/livreur.dart';
import '../utils/api_urls.dart';
import './livreur_service.dart';
class LocationSenderService {
  final SocketService socketService = SocketService(ApiUrls.socketUrl);
  late StreamSubscription<Position> _locationSubscription;

  LocationSenderService() {
    _startSendingLocation();
  }

  void _startSendingLocation() {
    _locationSubscription = LocationService().locationStream.listen((Position position) async {
      try {
        Livreur? livreur = await LivreurService.getLivreurSession();
        socketService.sendLocation(position.latitude, position.longitude, livreur!.id);
        print('Localisation envoyée: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        print('Erreur lors de l\'envoi de la localisation au serveur : $e');
      }
    });
  }

  void dispose() {
    _locationSubscription.cancel();
  }
}
