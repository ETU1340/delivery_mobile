import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final success = await AuthService.login(_username, _password);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connexion avec succès")),
        );
        Navigator.pushNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Compte introuvable")),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.red))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Couleur de fond pour une meilleure lisibilité
      appBar: AppBar(
        title: Text('Connexion'),
        backgroundColor: Colors.blue, // Couleur principale
        elevation: 0, 
        automaticallyImplyLeading: false,// Suppression de l'ombre pour un design plus minimaliste
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centrer le contenu verticalement
            children: <Widget>[
              Text(
                'Bienvenue',
                style: TextStyle(
                  fontSize: 24, // Taille de la police plus grande pour les titres
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Couleur principale
                ),
              ),
              SizedBox(height: 20), // Espacement supplémentaire pour l'esthétique
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  labelStyle: TextStyle(color: Colors.blue), // Couleur du label
                  border: OutlineInputBorder(), // Bordure pour améliorer la lisibilité
                ),
                onSaved: (value) => _username = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom d\'utilisateur';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), // Espacement entre les champs
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onSaved: (value) => _password = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30), // Espacement avant le bouton
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Couleur principale du bouton
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Ajustement du padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Arrondi du bouton pour un design moderne
                  ),
                ),
                child: Text(
                  'Connexion',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
