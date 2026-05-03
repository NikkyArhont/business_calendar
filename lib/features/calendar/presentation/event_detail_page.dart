import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:business_calendar/core/models/calendar_event.dart';
import 'package:business_calendar/config/constants/app_colors.dart';

class EventDetailPage extends StatelessWidget {
  final CalendarEvent event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final weekDays = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    
    final dateStr = '${weekDays[event.startTime.weekday - 1]}, ${event.startTime.day} ${months[event.startTime.month - 1]}';
    final timeStr = event.isAllDay 
        ? 'Весь день' 
        : '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Custom Top Bar
              _buildTopBar(context),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Header
                      if (event.selectedContacts.isNotEmpty)
                        _buildContactHeader(event.selectedContacts.first),
                      
                      const Divider(height: 1, color: Color(0xFFF2F2F7)),

                      // Title
                      _buildSectionTitle(event.title, isMain: true),

                      const Divider(height: 1, color: Color(0xFFF2F2F7)),

                      // Date & Time
                      _buildInfoSection(dateStr, timeStr),

                      const Divider(height: 1, color: Color(0xFFF2F2F7)),

                      // Type
                      _buildLabelValueSection('Тип события', event.type ?? 'Личная'),

                      const Divider(height: 1, color: Color(0xFFF2F2F7)),

                      // Repeat
                      _buildLabelValueSection('Повтор', event.repeat ?? 'Никогда'),

                      const Divider(height: 1, color: Color(0xFFF2F2F7)),

                      // Note
                      _buildNoteSection('Заметка', event.note),

                      const Divider(height: 1, color: Color(0xFFF2F2F7)),

                      // Problem
                      _buildLabelValueSection(
                        'Проблема', 
                        event.clientPainPoints.isNotEmpty 
                          ? event.clientPainPoints.join(', ') 
                          : 'Нет данных'
                      ),

                      const Divider(height: 1, color: Color(0xFFF2F2F7)),

                      // Solution
                      _buildLabelValueSection(
                        'Решение', 
                        event.solutions.isNotEmpty 
                          ? event.solutions.join(', ') 
                          : 'Нет данных'
                      ),

                      const Divider(height: 1, color: Color(0xFFF2F2F7)),

                      // Files
                      if (event.fileUrls.isNotEmpty)
                        _buildFilesSection(event.fileUrls),
                      
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContactHeader(Map<String, dynamic> contact) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage("https://placehold.co/40x40"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: ShapeDecoration(
                    color: const Color(0x0FFA4E02),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Статус контакта',
                    style: TextStyle(
                      color: Color(0xFFFA4E02),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  contact['name'] ?? 'Без имени',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isMain = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: isMain ? 20 : 16,
          fontWeight: isMain ? FontWeight.w400 : FontWeight.w500,
          letterSpacing: -0.31,
        ),
      ),
    );
  }

  Widget _buildInfoSection(String date, String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValueSection(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesSection(List<String> urls) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Файлы',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: urls.map((url) => Container(
                width: 110,
                height: 110,
                margin: const EdgeInsets.only(right: 8),
                decoration: ShapeDecoration(
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/110x110"),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(String label, String? note) {
    if (note == null || note.isEmpty) {
      return _buildLabelValueSection(label, 'Нет заметок');
    }

    quill.QuillController? quillController;
    bool isRichText = false;

    try {
      final json = jsonDecode(note);
      if (json is List) {
        quillController = quill.QuillController(
          document: quill.Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
        );
        isRichText = true;
      }
    } catch (e) {
      isRichText = false;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          isRichText
              ? quill.QuillEditor.basic(
                  controller: quillController!,
                  configurations: const quill.QuillEditorConfigurations(
                    readOnly: true,
                  ),
                )
              : Text(
                  note,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
        ],
      ),
    );
  }
}
