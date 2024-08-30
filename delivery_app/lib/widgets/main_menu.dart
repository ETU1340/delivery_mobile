import 'package:flutter/material.dart';
import '../screens/delivery_map_screen.dart';
import '../widgets/delivery_schedule.dart';
import '../screens/create_unavailability_screen.dart'; // Demande d'indisponibilité
import '../screens/list_unavailability_screen.dart';
import '../services/location_service.dart';
import '../services/livreur_service.dart';
import '../models/livreur.dart';
import '../screens/chat_screen.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LocationService locationService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    locationService = LocationService(onError: _showError, onSuccess: _showSuccess);
  }

  @override
  void dispose() {
    locationService.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.red))),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.green))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application de Livraison'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Liste des indisponibilités"),
            Tab(text: "Demande d'indisponibilité"),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu Principal'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text("Carte des livraisons"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryMapScreen()));
              },
            ),
            ListTile(
              title: Text("Planning des livraisons"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => DeliverySchedule()));
              },
            ),
              ListTile(
              title: Text("Indisponnibilité"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainMenu()));
              },
            ),
              ListTile(
              title: Text("Discussion avec le manager"), // Nouvelle option pour le chat
              onTap: () async {
                Navigator.pop(context);

                Livreur? livreur =   await LivreurService.getLivreurSession();

                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                  roomId: livreur!.id,  // Utilisez un identifiant unique pour la salle de chat
                  delivererId: livreur!.id,  // Remplacez par l'ID du livreur
                  managerId: livreur!.managerId!,  // Remplacez par l'ID du manager
                )));
                   },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          UnavailabilityList(), // Liste des indisponibilités
          UnavailabilityForm(), // Demande d'indisponibilité
        ],
      ),
    );
  }
}