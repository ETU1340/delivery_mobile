import 'package:flutter/material.dart';
import '../screens/delivery_map_screen.dart';
import '../widgets/delivery_schedule.dart';
import '../screens/create_unavailability_screen.dart'; // Demande d'indisponibilité
import '../screens/list_unavailability_screen.dart';
import '../services/location_sender_service.dart';
import '../services/livreur_service.dart';
import '../services/auth_service.dart'; // Service d'authentification pour la déconnexion
import '../models/livreur.dart';
import '../screens/chat_screen.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LocationSenderService locationService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    locationService = LocationSenderService();
  }

  @override
  void dispose() {
    locationService.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    Navigator.pushReplacementNamed(context, '/login'); // Redirige vers l'écran de login après la déconnexion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livraison', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue, // Couleur principale de l'application
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white, // Couleur de l'indicateur sous les onglets
          tabs: [
            Tab(
              icon: Icon(Icons.list_alt),
              text: "Indisponibilités",
            ),
            Tab(
              icon: Icon(Icons.add_circle_outline),
              text: "Demande",
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue, // Couleur principale pour le header
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.map, color: Colors.blue),
              title: Text("Carte"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryMapScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.blue),
              title: Text("Planning"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => DeliverySchedule()));
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.blue),
              title: Text("Indisponibilité"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainMenu()));
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.blue),
              title: Text("Discussion"),
              onTap: () async {
                Navigator.pop(context);

                Livreur? livreur = await LivreurService.getLivreurSession();
                print(livreur!.managerId!);

                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                  roomId: livreur!.id,  // Utilisez un identifiant unique pour la salle de chat
                  delivererId: livreur!.id,  // Remplacez par l'ID du livreur
                  managerId: livreur!.managerId!,
                  role: livreur!.role!,
                  name:livreur!.name  // Remplacez par l'ID du manager
                )));
              },
            ),
            Divider(), // Ligne de séparation avant le bouton de déconnexion
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Déconnexion", style: TextStyle(color: Colors.red)),
              onTap: _logout, // Appel de la fonction de déconnexion
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
