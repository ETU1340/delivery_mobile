// services/driver_service.dart
import 'package:delivery_app/models/driver.dart';

class DriverService {
  // Liste des livreurs de test
  List<Driver> getDrivers() {
    return [
      Driver(id: '1', name: 'Livreur 1', status: 'Disponible'),
      Driver(id: '2', name: 'Livreur 2', status: 'Occupé'),
      // Ajoutez d'autres livreurs ici
    ];
  }
}
