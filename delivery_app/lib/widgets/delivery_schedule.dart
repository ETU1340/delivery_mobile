import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/delivery_service.dart';
import'../screens/delivery_map_screen.dart';

class DeliverySchedule extends StatefulWidget {
  @override
  _DeliveryScheduleState createState() => _DeliveryScheduleState();
}

class _DeliveryScheduleState extends State<DeliverySchedule> {
  final DeliveryService deliveryService = DeliveryService();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planning des Livraisons'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
          ),
          Expanded(
            child: ListView(
              children: deliveryService.deliveries
                  .where((delivery) =>
                      delivery.dateTime.year == _selectedDay.year &&
                      delivery.dateTime.month == _selectedDay.month &&
                      delivery.dateTime.day == _selectedDay.day)
                  .map((delivery) {
                    return ListTile(
                      title: Text(delivery.title),
                      subtitle: Text(
                        'Heure: ${delivery.dateTime.toLocal().toString().split(' ')[1]} - Statut: ${delivery.status}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'localisation') {
                            // Navigate to the map screen with the delivery location
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeliveryMapScreen(deliveryId:delivery.id),
                              ),
                            );
                          } else if (value == 'validation') {
                            // Prompt for validation code
                            _showValidationDialog(context, delivery.id);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: 'localisation',
                              child: Text('Voir sur la carte'),
                            ),
                            PopupMenuItem(
                              value: 'validation',
                              child: Text('Valider la livraison'),
                            ),
                          ];
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showValidationDialog(BuildContext context, String deliveryId) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Validation de la Livraison'),
          content: TextField(
            controller: codeController,
            decoration: InputDecoration(hintText: 'Entrez le code de validation'),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Valider'),
              onPressed: () {
                // Vérifiez le code de validation ici
                if (codeController.text == '1234') { // exemple de code correct
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Livraison validée')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Code incorrect'), backgroundColor: Colors.red),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
