import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:business_calendar/core/models/calendar_event.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/shared/widgets/app_alert_dialog.dart';
import 'package:business_calendar/core/services/firestore_service.dart';
import 'package:flutter/foundation.dart';
import 'package:business_calendar/features/calendar/presentation/add_event_page.dart';

class EventDetailPage extends StatelessWidget {
  final CalendarEvent event;
  final bool isEmbedded;
  final VoidCallback? onBack;

  const EventDetailPage({
    super.key, 
    required this.event,
    this.isEmbedded = false,
    this.onBack,
  });

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

    final content = Column(
      children: [
        // Custom Top Bar
        _buildTopBar(context, dateStr),
        
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
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
            ),
          ),
          if (isEmbedded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _editEvent(context),
                      icon: const Icon(Icons.edit, size: 18, color: Color(0xFFFA4E02)),
                      label: const Text('Редактировать', style: TextStyle(color: Color(0xFFFA4E02), fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFA4E02).withOpacity(0.1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _deleteEvent(context),
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                      label: const Text('Удалить', style: TextStyle(color: Colors.white, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE54D4D),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );

    if (isEmbedded) {
      return Container(
        color: const Color(0xFFF7F6F2),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: content,
      ),
    );
  }

  void _editEvent(BuildContext context) {
    if (kIsWeb || MediaQuery.of(context).size.width > 800) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: 600,
            height: 800,
            child: AddEventPage(eventToEdit: event),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddEventPage(eventToEdit: event)),
      );
    }
  }

  void _deleteEvent(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AppAlertDialog(
        title: 'Вы уверены, что хотите удалить событие?',
        actionTitle: 'Удалить',
        isDestructive: true,
        onAction: () async {
          await FirestoreService().deleteEvent(event.id);
          if (context.mounted) {
            if (isEmbedded && onBack != null) {
              onBack!();
            } else {
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String dateStr) {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          if (isEmbedded)
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFFFA4E02)),
              label: Text(
                dateStr,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
            )
          else
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          const Spacer(),
          if (!isEmbedded) ...[
            IconButton(
              icon: Image.asset('assets/edit.png', width: 24, height: 24),
              onPressed: () => _editEvent(context),
            ),
            IconButton(
              icon: Image.asset('assets/trash.png', width: 24, height: 24),
              onPressed: () => _deleteEvent(context),
            ),
          ],
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
          readOnly: true,
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
                  config: const quill.QuillEditorConfig(
                    scrollable: false,
                    autoFocus: false,
                    expands: false,
                    padding: EdgeInsets.zero,
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
