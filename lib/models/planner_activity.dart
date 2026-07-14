import 'package:flutter/material.dart';

class PlannerActivity {
  final String id;
  final String name;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int colorValue;

  const PlannerActivity({
    required this.id,
    required this.name,
    required this.startDateTime,
    required this.endDateTime,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  Duration get duration => endDateTime.difference(startDateTime);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'colorValue': colorValue,
    };
  }

  factory PlannerActivity.fromMap(Map<String, dynamic> map, String docId) {
    return PlannerActivity(
      id: docId,
      name: map['name'] ?? '',
      startDateTime: DateTime.parse(map['startDateTime']),
      endDateTime: DateTime.parse(map['endDateTime']),
      colorValue: map['colorValue'] ?? PlannerActivity.defaultPalette.first.toARGB32(),
    );
  }

  PlannerActivity copyWith({
    String? id,
    String? name,
    DateTime? startDateTime,
    DateTime? endDateTime,
    int? colorValue,
  }) {
    return PlannerActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  static const defaultPalette = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF84CC16),
  ];

  static int defaultColorForIndex(int index) {
    return defaultPalette[index % defaultPalette.length].toARGB32();
  }
}
