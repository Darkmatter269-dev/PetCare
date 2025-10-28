import 'package:flutter/material.dart';

class Pet {
  final String id;
  String name;
  String breed;
  String gender;
  String age;
  String colour;
  String height;
  String weight;
  String notes;
  Color avatarColor;

  Pet({
    required this.id,
    required this.name,
    this.breed = '',
    this.gender = '',
    this.age = '',
    this.colour = '',
    this.height = '',
    this.weight = '',
    this.notes = '',
    this.avatarColor = const Color(0xFF97E8C6),
  });
}