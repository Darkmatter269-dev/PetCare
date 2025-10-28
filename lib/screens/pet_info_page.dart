import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../models/pet_store.dart';

class PetInfoPage extends StatelessWidget {
  final Pet pet;
  const PetInfoPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final current = context.select<PetStore, Pet?>(
      (store) => store.byId(pet.id),
    ) ?? pet;

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
              CircleAvatar(
                radius: 38,
                backgroundColor: current.avatarColor,
                child: (current.photoPath != null && File(current.photoPath!).existsSync())
                    ? ClipOval(
                        child: Image.file(
                          File(current.photoPath!),
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(current.name.isEmpty ? '' : current.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(current.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(current.breed.isEmpty ? 'Unknown breed' : current.breed, style: TextStyle(color: Colors.grey[600])),
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