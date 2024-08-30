import 'package:flutter/material.dart';
import 'widgets/main_menu.dart';
import './screens/login_screen.dart';
import 'services/socket_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketService('http://localhost:8080')),
      ],
      child: MyApp(),
    ),
  );
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