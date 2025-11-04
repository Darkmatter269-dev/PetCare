import 'package:flutter/foundation.dart';

class MedicalRecord {
  final DateTime dateOfVisit;
  final String vetName;
  final String diagnosis;
  final String medication;
  final DateTime? nextAppointment;

  MedicalRecord({
    required this.dateOfVisit,
    required this.vetName,
    required this.diagnosis,
    required this.medication,
    this.nextAppointment,
  });

  String formattedDate() => '${dateOfVisit.month}/${dateOfVisit.day}/${dateOfVisit.year}';
}
