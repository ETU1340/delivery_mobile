import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UnavailabilityForm extends StatefulWidget {
  @override
  _UnavailabilityFormState createState() => _UnavailabilityFormState();
}

class _UnavailabilityFormState extends State<UnavailabilityForm> {
  final _formKey = GlobalKey<FormState>();
  String _reason = '';
  DateTime? _startDate;
  DateTime? _endDate;

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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // Traiter les données du formulaire ici
      print('Raison: $_reason');
      print('Date de début: $_startDate');
      print('Date de fin: $_endDate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signaler une indisponibilité')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Raison'),
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
                title: Text('Date de début: ${_startDate != null ? DateFormat.yMd().format(_startDate!) : 'Sélectionner une date'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickStartDate,
              ),
              ListTile(
                title: Text('Date de fin: ${_endDate != null ? DateFormat.yMd().format(_endDate!) : 'Sélectionner une date'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickEndDate,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
