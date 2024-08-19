import 'package:flutter/material.dart';
import 'widgets/main_menu.dart';
import './services/location_service.dart';
import './screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => MainMenu(),
      },
      home: MainMenu(), // Définit MainMenu comme la vue principale
    );
  }
}