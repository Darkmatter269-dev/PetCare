import 'dart:io';

import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/medical_record.dart';

class VetLogPage extends StatefulWidget {
  final Pet pet;
  const VetLogPage({super.key, required this.pet});

  @override
  State<VetLogPage> createState() => _VetLogPageState();
}

class _VetLogPageState extends State<VetLogPage> {
  // Start with an empty list so the view only shows records added in the session.
  final List<MedicalRecord> _records = [];

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    return Scaffold(
      backgroundColor: const LinearGradient(
        colors: [Color(0xFFF7FBFC), Color(0xFFFFFFFF)],
      ).colors.first, // simple light background approximation
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Vet Log', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _petCard(pet),
            const SizedBox(height: 18),
            const Text('Medical History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Expanded(child: _historyList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddRecord,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _petCard(Pet pet) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: pet.avatarColor,
          child: (pet.photoPath != null && File(pet.photoPath!).existsSync())
              ? ClipOval(child: Image.file(File(pet.photoPath!), width: 56, height: 56, fit: BoxFit.cover))
              : Text(pet.name.isEmpty ? '' : pet.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pet.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(pet.breed.isEmpty ? 'Unknown breed' : pet.breed, style: TextStyle(color: Colors.grey[600])),
          ]),
        ),
      ]),
    );
  }

  Widget _historyList() {
    if (_records.isEmpty) {
      return const Center(child: Text('No medical history yet', style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      itemCount: _records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final r = _records[idx];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Date of Visit: ${r.formattedDate()}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('Vet: ${r.vetName}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ]),
            const SizedBox(height: 8),
            Text('Diagnosis / Notes: ${r.diagnosis}'),
            const SizedBox(height: 8),
            Text('Medication: ${r.medication}', style: const TextStyle(color: Colors.teal)),
            const SizedBox(height: 8),
            Text('Next Appointment: ${r.nextAppointment == null ? 'N/A' : '${r.nextAppointment!.month}/${r.nextAppointment!.day}/${r.nextAppointment!.year}'}', style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        );
      },
    );
  }

  void _openAddRecord() async {
    DateTime? dateOfVisit;
    DateTime? nextAppointment;
    final vetController = TextEditingController();
    final diagnosisController = TextEditingController();
    final medicationController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 12),
                const Text('Add Medical Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                // Date picker
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (picked != null) setModalState(() => dateOfVisit = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Date of Visit', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text(dateOfVisit == null ? 'Select date' : '${dateOfVisit!.month}/${dateOfVisit!.day}/${dateOfVisit!.year}'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(controller: vetController, decoration: const InputDecoration(labelText: 'Vet Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: diagnosisController, maxLines: 3, decoration: const InputDecoration(labelText: 'Diagnosis / Notes', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: medicationController, decoration: const InputDecoration(labelText: 'Medication', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                // Next appointment optional
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (picked != null) setModalState(() => nextAppointment = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Next Appointment (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text(nextAppointment == null ? 'N/A' : '${nextAppointment!.month}/${nextAppointment!.day}/${nextAppointment!.year}'),
                  ),
                ),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // basic validation
                      if (dateOfVisit == null || vetController.text.trim().isEmpty) {
                        // show simple feedback
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please choose a date and enter vet name')));
                        return;
                      }

                      final record = MedicalRecord(
                        dateOfVisit: dateOfVisit!,
                        vetName: vetController.text.trim(),
                        diagnosis: diagnosisController.text.trim(),
                        medication: medicationController.text.trim().isEmpty ? 'None' : medicationController.text.trim(),
                        nextAppointment: nextAppointment,
                      );
                      setState(() => _records.insert(0, record));
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text('Save'),
                  ),
                ])
              ]),
            );
          }),
        );
      },
    );
  }
}
