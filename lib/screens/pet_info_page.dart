import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetInfoPage extends StatelessWidget {
  final Pet pet;
  const PetInfoPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with explicit back-to-home button
      appBar: AppBar(
        title: const Text('Pet Info'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // navigate back to home page
            Navigator.of(context).pushReplacementNamed('/home');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))]),
            child: Row(children: [
              CircleAvatar(radius: 38, backgroundColor: pet.avatarColor, child: Text(pet.name.isEmpty ? '' : pet.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(pet.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(pet.breed.isEmpty ? 'Unknown breed' : pet.breed, style: TextStyle(color: Colors.grey[600])),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                _infoRow('Gender', pet.gender),
                _infoRow('Age', pet.age),
                _infoRow('Colour', pet.colour),
                _infoRow('Height', pet.height),
                _infoRow('Weight', pet.weight),
                const SizedBox(height: 12),
                const Text('Notes', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(pet.notes.isEmpty ? 'No notes' : pet.notes, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
        const SizedBox(width: 12),
        Text(value.isEmpty ? '-' : value, style: TextStyle(color: Colors.grey[700])),
      ]),
    );
  }
}