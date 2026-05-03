import 'package:flutter/material.dart';

class CalendarEvent {
  final String id;
  final String title;
  final List<Map<String, dynamic>> selectedContacts;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String repeat; // Never, Daily, Weekly, etc.
  final String? type;
  final int colorValue;
  final List<String> clientPainPoints;
  final List<String> solutions;
  final String? note;
  final List<String> fileUrls;
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.title,
    this.selectedContacts = const [],
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.repeat = 'Никогда',
    this.type,
    this.colorValue = 0xFFFA4E02,
    this.clientPainPoints = const [],
    this.solutions = const [],
    this.note,
    this.fileUrls = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'selectedContacts': selectedContacts,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
      'repeat': repeat,
      'type': type,
      'colorValue': colorValue,
      'clientPainPoints': clientPainPoints,
      'solutions': solutions,
      'note': note,
      'fileUrls': fileUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> map, String documentId) {
    return CalendarEvent(
      id: documentId,
      title: map['title'] ?? '',
      selectedContacts: List<Map<String, dynamic>>.from(map['selectedContacts'] ?? []),
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      isAllDay: map['isAllDay'] ?? false,
      repeat: map['repeat'] ?? 'Никогда',
      type: map['type'],
      colorValue: map['colorValue'] ?? 0xFFFA4E02,
      clientPainPoints: List<String>.from(map['clientPainPoints'] ?? []),
      solutions: List<String>.from(map['solutions'] ?? []),
      note: map['note'],
      fileUrls: List<String>.from(map['fileUrls'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
