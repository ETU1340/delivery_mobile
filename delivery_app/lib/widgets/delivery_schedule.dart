import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/delivery_service.dart';
import '../screens/delivery_map_screen.dart';
import '../models/delivery.dart';
import 'package:intl/intl.dart'; // Importation pour le formatage de l'heure

class DeliverySchedule extends StatefulWidget {
  @override
  _DeliveryScheduleState createState() => _DeliveryScheduleState();
}

class _DeliveryScheduleState extends State<DeliverySchedule> {
  List<Delivery> _deliveries = []; // Liste des livraisons
  DateTime _selectedDay = DateTime.now();
  final DateFormat _timeFormat = DateFormat('HH:mm'); // Format d'heure

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    try {
      final deliveries = await DeliveryService.getDeliveries();
      setState(() {
        _deliveries = deliveries;
      });
    } catch (e) {
      // Gestion des erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des livraisons')),
      );
    }
  }

  // Méthode pour obtenir la couleur en fonction du statut de la livraison
  Color _getColorForStatus(String status) {
    switch (status) {
      case 'En attente':
        return Colors.orange; // Couleur pour les livraisons "En attente"
      case 'En cours':
        return Colors.blue; // Couleur pour les livraisons "En cours"
      case 'Terminé':
        return Colors.green; // Couleur pour les livraisons "Terminé"
      case 'Annulé':
        return Colors.red; // Couleur pour les livraisons "Annulé"
      default:
        return Colors.grey; // Couleur par défaut pour les autres statuts
    }
  }

  // Vérifier si la livraison est aujourd'hui (sans tenir compte de l'heure)
  bool _isDeliveryToday(Delivery delivery) {
    final now = DateTime.now();
    return now.year == delivery.deliveryDateTimeBegin.year &&
           now.month == delivery.deliveryDateTimeBegin.month &&
           now.day == delivery.deliveryDateTimeBegin.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planning des Livraisons', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
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
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(), // Séparateur entre les livraisons
              itemCount: _deliveries
                  .where((delivery) =>
                      delivery.deliveryDateTimeBegin.year == _selectedDay.year &&
                      delivery.deliveryDateTimeBegin.month == _selectedDay.month &&
                      delivery.deliveryDateTimeBegin.day == _selectedDay.day)
                  .length,
              itemBuilder: (context, index) {
                final delivery = _deliveries
                    .where((delivery) =>
                        delivery.deliveryDateTimeBegin.year == _selectedDay.year &&
                        delivery.deliveryDateTimeBegin.month == _selectedDay.month &&
                        delivery.deliveryDateTimeBegin.day == _selectedDay.day)
                    .toList()[index];

                return ListTile(
                  title: Text(
                    "${delivery.reference}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Heure Debut: ${_timeFormat.format(delivery.deliveryDateTimeBegin)} - Heure Fin: ${_timeFormat.format(delivery.deliveryDateTimeEnd)}',
                    style: TextStyle(color: _getColorForStatus(delivery.status)), // Appliquer couleur au sous-titre
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Afficher le bouton de localisation uniquement pour les livraisons aujourd'hui
                      if (_isDeliveryToday(delivery))
                        IconButton(
                          icon: Icon(Icons.map, color: _getColorForStatus(delivery.status)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeliveryMapScreen(deliveryId: delivery.id),
                              ),
                            );
                          },
                        ),
                      // Afficher le bouton selon le statut
                      if (delivery.status == 'En attente')
                        IconButton(
                          icon: Icon(Icons.play_circle_outline, color: _getColorForStatus(delivery.status)),
                          onPressed: () async {
                            // Vérifier si une autre livraison est "En cours"
                            bool hasOngoingDelivery = _deliveries.any((d) => d.status == 'En cours' && d.deliveryDateTimeEnd.isBefore(delivery.deliveryDateTimeEnd) && d.deliveryDateTimeBegin.isAfter(delivery.deliveryDateTimeBegin));
                            if (hasOngoingDelivery) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Impossible de prendre en charge cette livraison. Une autre livraison est déjà en cours.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              await _takeChargeDelivery(delivery);
                            }
                          },
                        )
                      else if (delivery.status == 'En cours')
                        IconButton(
                          icon: Icon(Icons.check_circle_outline, color: _getColorForStatus(delivery.status)),
                          onPressed: () {
                            _showValidationDialog(context, delivery.id, delivery.validationCode);
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takeChargeDelivery(Delivery delivery) async {
    try {
      await DeliveryService.updateDeliveryStatus(delivery.id, 'En cours');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Livraison prise en charge')),
      );
      _loadDeliveries(); // Recharger les livraisons après la mise à jour du statut
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la prise en charge de la livraison'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showValidationDialog(BuildContext context, String deliveryId, String code) {
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
              onPressed: () async {
                if (codeController.text == code) {
                  try {
                    await DeliveryService.updateDeliveryStatus(deliveryId, 'Terminé');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Livraison validée')),
                    );
                    Navigator.of(context).pop();
                    _loadDeliveries(); // Recharger les livraisons après la validation
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la validation de la livraison'), backgroundColor: Colors.red),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Code incorrect'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
