import 'package:flutter/material.dart';

class UnavailabilityList extends StatelessWidget {
  final List<Map<String, dynamic>> unavailabilityList = [
    {"reason": "Congé", "startDate": "2024-09-01", "endDate": "2024-09-05", "status": "Approuvé"},
    {"reason": "Maladie", "startDate": "2024-09-10", "endDate": "2024-09-15", "status": "En attente"},
    // Ajoutez plus de données ici
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Permet de faire défiler horizontalement
      child: DataTable(
        columns: [
          DataColumn(label: Text('Raison')),
          DataColumn(label: Text('Date Début')),
          DataColumn(label: Text('Date Fin')),
          DataColumn(label: Text('Statut')),
        ],
        rows: unavailabilityList.map((unavailability) {
          Color statusColor;
          switch (unavailability['status']) {
            case 'Approuvé':
              statusColor = Colors.green;
              break;
            case 'En attente':
              statusColor = Colors.orange;
              break;
            case 'Refusé':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.grey;
          }

          return DataRow(cells: [
            DataCell(Text(unavailability['reason'])),
            DataCell(Text(unavailability['startDate'])),
            DataCell(Text(unavailability['endDate'])),
            DataCell(Text(
              unavailability['status'],
              style: TextStyle(color: statusColor),
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
