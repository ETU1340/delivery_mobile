import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http; // Pour les appels HTTP
import 'dart:convert'; // Pour la manipulation JSON
import '../utils/api_urls.dart';
import '../services/livreur_service.dart';
import '../models/livreur.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UnavailabilityForm extends StatefulWidget {
  @override
  _UnavailabilityFormState createState() => _UnavailabilityFormState();
}

class _UnavailabilityFormState extends State<UnavailabilityForm> {
  final _formKey = GlobalKey<FormState>();
  String _reason = '';
  DateTime? _startDate;
  DateTime? _endDate;

  // Méthode pour sélectionner la date de début
  void _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  // Méthode pour sélectionner la date de fin
  void _pickEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  // Fonction pour soumettre le formulaire
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Traiter les données du formulaire ici
      print('Raison: $_reason');
      print('Date de début: $_startDate');
      print('Date de fin: $_endDate');

      // Appel API pour sauvegarder la demande d'indisponibilité
      await _saveUnavailability();
    }
  }

  // Fonction pour sauvegarder la demande d'indisponibilité via un appel API
  Future<void> _saveUnavailability() async {
    Livreur? livreur = await LivreurService.getLivreurSession();
    try {
      final url = Uri.parse(ApiUrls.livreurs + "/" + livreur!.id + "/unavailable"); // Remplacez par l'URL de votre API
      print(url);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'x-auth-token': '$token', // Ajoutez un token d'autorisation si nécessaire
        },
        body: jsonEncode({
          'reason': _reason,
          'startDate': _startDate?.toIso8601String(),
          'endDate': _endDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        // Succès de l'API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demande d\'indisponibilité sauvegardée avec succès')),
        );
       // Navigator.pop(context); // Fermer le formulaire après soumission
      } else {
        // Erreur de l'API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde de la demande')),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'appel API: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi de la demande')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Indisponibilité',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Raison de l\'indisponibilité',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Entrez la raison',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSaved: (value) {
                  _reason = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une raison';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                title: Text(
                  'Date de début',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                subtitle: Text(
                  _startDate != null
                      ? DateFormat.yMd().format(_startDate!)
                      : 'Sélectionner une date',
                  style: TextStyle(color: Colors.black),
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.blueAccent),
                onTap: _pickStartDate,
              ),
              SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                title: Text(
                  'Date de fin',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                subtitle: Text(
                  _endDate != null
                      ? DateFormat.yMd().format(_endDate!)
                      : 'Sélectionner une date',
                  style: TextStyle(color: Colors.black),
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.blueAccent),
                onTap: _pickEndDate,
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: Icon(Icons.send, color: Colors.white),
                  label: Text(
                    'Soumettre',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
