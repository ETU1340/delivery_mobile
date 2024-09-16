import 'location.dart';
import 'livreur.dart';

class Delivery {
  final String id;
  final String clientName;
  final String clientSurname;
  final String clientEmail;
  final String validationCode;
  final String reference;
  final Location deliveryAddress;
  final DateTime deliveryDateTimeBegin;  // Combined DateTime field
  final DateTime deliveryDateTimeEnd;  // Combined DateTime field
  String status;
  final String livreurId;
  final Livreur? livreur;
  final String managerId;

  Delivery({
    required this.id,
    required this.clientName,
    required this.clientSurname,
    required this.clientEmail,
    required this.validationCode,
    required this.reference,
    required this.deliveryAddress,
    required this.deliveryDateTimeBegin,  // Combined DateTime field
    required this.deliveryDateTimeEnd,
    required this.status,
    required this.livreurId,
    this.livreur,
    required this.managerId,
  });

factory Delivery.fromJson(Map<String, dynamic> json) {
  return Delivery(
    id: json['_id'] ?? '',
    clientName: json['clientName'] ?? '',
    clientSurname: json['clientSurname'] ?? '',
    clientEmail: json['clientEmail'] ?? '',
    validationCode: json['validationCode'] ?? '',
    reference: json['reference'] ?? '',
    deliveryAddress: Location.fromJson(json['deliveryAddress'] ?? {}),
    deliveryDateTimeBegin: DateTime.parse(json['deliveryDateTimeBegin'] ?? ''),
    deliveryDateTimeEnd: DateTime.parse(json['deliveryDateTimeEnd'] ?? ''),
    status: json['status'] ?? '',
    livreurId: json['livreurId'] != null && json['livreurId'] is Map<String, dynamic> 
        ? (json['livreurId']['_id'] ?? '')
        : '',
    livreur: json['livreurId'] != null && json['livreurId'] is Map<String, dynamic> 
        ? Livreur.fromJson(json['livreurId'] as Map<String, dynamic>)
        : null,
    managerId: json['managerId'] ?? '',
  );
}



  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'clientSurname': clientSurname,
      'clientEmail': clientEmail,
      'validationCode': validationCode,
      'reference': reference,
      'deliveryAddress': deliveryAddress.toJson(),
      'deliveryDateTimeBegin': deliveryDateTimeBegin.toIso8601String(),  // Combined DateTime field
      'deliveryDateTimeEnd': deliveryDateTimeEnd,
      'status': status,
      'livreurId': livreurId,
      'livreur': livreur?.toJson(),  // Serializing the nested Livreur object
      'managerId': managerId,
    };
  }
}
