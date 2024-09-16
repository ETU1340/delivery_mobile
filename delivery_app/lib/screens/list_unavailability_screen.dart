import 'package:flutter/material.dart';
import '../models/livreur.dart';
import '../services/livreur_service.dart';

class UnavailabilityList extends StatefulWidget {
  @override
  _UnavailabilityListState createState() => _UnavailabilityListState();
}

class _UnavailabilityListState extends State<UnavailabilityList> {
  Livreur? _livreur;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLivreur();
  }

  // Méthode pour charger le livreur connecté
  Future<void> _loadLivreur() async {
    try {
      Livreur? livreur = await LivreurService.getLivreurSession();
      Livreur? livreurs = await LivreurService.getLivreurById(livreur!.id);
      setState(() {
        _livreur = livreurs;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Affiche un indicateur de chargement pendant que les données se chargent
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Si aucun livreur n'est disponible ou aucune période d'indisponibilité n'existe
    if (_livreur == null || _livreur!.unavailablePeriods == null || _livreur!.unavailablePeriods!.isEmpty) {
      return Center(child: Text('Aucune indisponibilité trouvée.'));
    }

    // Création du tableau de données à partir des périodes d'indisponibilité du livreur
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Permet de faire défiler horizontalement
      child: DataTable(
        columns: [
          DataColumn(label: Text('Raison')),
          DataColumn(label: Text('Date Début')),
          DataColumn(label: Text('Date Fin')),
          DataColumn(label: Text('Statut')),
        ],
        rows: _livreur!.unavailablePeriods!.map((unavailability) {
          print(unavailability.status);
          Color statusColor;
          switch (unavailability.status) {
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
            DataCell(Text(unavailability.reason)),
            DataCell(Text(_formatDate(unavailability.startDate))),
            DataCell(Text(_formatDate(unavailability.endDate))),
            DataCell(Text(
              unavailability.status,
              style: TextStyle(color: statusColor),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // Méthode utilitaire pour formater les dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
