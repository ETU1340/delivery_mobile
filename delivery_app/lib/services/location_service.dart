/*
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal() {
    _startTracking();
  }

  final StreamController<Position> _locationController = StreamController<Position>.broadcast();
  Stream<Position> get locationStream => _locationController.stream;
  Timer? _timer;

  void _startTracking() {
    _timer = Timer.periodic(Duration(seconds: 8), (Timer timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        _locationController.add(position);
      } catch (e) {
        print('Erreur lors de la récupération de la localisation : $e');
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _locationController.close();
  }
}
*/
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal() {
    _init();
  }

  final StreamController<Position> _locationController = StreamController<Position>.broadcast();
  Stream<Position> get locationStream => _locationController.stream;
  StreamSubscription<Position>? _positionStreamSubscription;

  Future<void> _init() async {
    // Demander les autorisations et activer le suivi si les autorisations sont accordées
    bool permissionGranted = await _requestLocationPermission();
    if (permissionGranted) {
      bool serviceEnabled = await _isLocationServiceEnabled();
      if (serviceEnabled) {
        _startTracking();
      }
    }
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  Future<bool> _isLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return await Geolocator.openLocationSettings();
    }
    return serviceEnabled;
  }

  void _startTracking() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _locationController.add(position);
    });
  }

  void dispose() {
    _positionStreamSubscription?.cancel();
    _locationController.close();
  }
}
