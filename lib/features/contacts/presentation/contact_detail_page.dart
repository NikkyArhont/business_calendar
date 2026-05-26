import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/calendar_event.dart';
import '../../../features/calendar/presentation/event_detail_page.dart';
import 'add_contact_page.dart';
import '../../../shared/widgets/app_alert_dialog.dart';

class ContactDetailPage extends StatefulWidget {
  final String contactId;
  final bool isWebModule;

  const ContactDetailPage({
    super.key,
    required this.contactId,
    this.isWebModule = false,
  });

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  int _selectedSegment = 0; // 0 for Visits, 1 for Files
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _contactData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<void> _loadContact() async {
    final data = await _firestoreService.getContact(widget.contactId);
    setState(() {
      _contactData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F6F2),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFA4E02))),
      );
    }

    if (_contactData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F6F2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: widget.isWebModule ? null : IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF), size: 22),
          ),
          automaticallyImplyLeading: !widget.isWebModule,
        ),
        body: const Center(child: Text('Контакт не найден')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F2),
        elevation: 0,
        leading: widget.isWebModule ? null : IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF), size: 22),
        ),
        automaticallyImplyLeading: !widget.isWebModule,
        actions: widget.isWebModule 
          ? [
              _buildWebButton(
                title: 'Редактировать',
                icon: Icons.edit,
                backgroundColor: const Color(0xFFFFF2E5),
                textColor: const Color(0xFFFA4E02),
                onTap: () {
                  if (_contactData != null) {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: 600,
                          height: 800,
                          child: AddContactPage(
                            contactId: widget.contactId,
                            initialData: _contactData,
                          ),
                        ),
                      ),
                    ).then((_) {
                      // Обновить данные после закрытия модального окна
                      _loadContact();
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildWebButton(
                title: 'Удалить',
                icon: Icons.delete_outline,
                backgroundColor: const Color(0xFFDF4A46),
                textColor: Colors.white,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Удалить контакт?'),
                      content: const Text('Это действие нельзя отменить.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true), 
                          child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _firestoreService.deleteContact(widget.contactId);
                  }
                },
              ),
              const SizedBox(width: 24),
            ]
          : [
              IconButton(
                onPressed: () {
                  if (_contactData != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddContactPage(
                          contactId: widget.contactId,
                          initialData: _contactData,
                        ),
                      ),
                    ).then((_) {
                      // Обновить данные после возврата
                      _loadContact();
                    });
                  }
                },
                icon: Image.asset('assets/edit.png', width: 24, height: 24),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (dialogContext) => AppAlertDialog(
                      title: 'Вы уверены, что хотите удалить контакт?',
                      actionTitle: 'Удалить',
                      isDestructive: true,
                      onAction: () async {
                        await _firestoreService.deleteContact(widget.contactId);
                        if (context.mounted) {
                          Navigator.pop(context); // Возвращаемся в список контактов
                        }
                      },
                    ),
                  );
                },
                icon: Image.asset('assets/trash.png', width: 24, height: 24),
              ),
              const SizedBox(width: 8),
            ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              children: [
                _buildProfileCard(),
                const SizedBox(height: 16),
                _buildSegmentedControl(),
                const SizedBox(height: 16),
                _buildVisitsSection(),
              ],
            ),
          ),
          if (!kIsWeb && !widget.isWebModule)
            Positioned(
              right: 16,
              bottom: 40,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFA4E02),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebButton({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: textColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final name = _contactData!['name'] ?? 'Без имени';
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    final phones = _contactData!['phones'] as List<dynamic>? ?? [];
    final phoneStr = phones.isNotEmpty ? phones.join(', ') : 'Нет данных';
    final email = _contactData!['email']?.toString().isNotEmpty == true ? _contactData!['email'] : 'Нет данных';
    
    final status = _contactData!['status']?.toString().isNotEmpty == true ? _contactData!['status'] : 'Новый';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Color(0xFFFA4E02),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFA4E02).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Color(0xFFFA4E02),
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Contact Details
          _buildInfoGroup('Контакты', [
            _buildInfoRow('Номер телефона', phoneStr),
            _buildInfoRow('Email', email),
          ]),
          
          Builder(builder: (context) {
            final trusted = _contactData!['trustedPerson'] as Map<String, dynamic>?;
            final trustedName = trusted?['name']?.toString() ?? '';
            final trustedPhone = trusted?['phone']?.toString() ?? '';
            
            return _buildInfoGroup('Контакты доверенного лица', [
              _buildInfoRow('Имя', trustedName.isNotEmpty ? trustedName : 'Нет данных'),
              _buildInfoRow('Номер телефона', trustedPhone.isNotEmpty ? trustedPhone : 'Нет данных'),
            ]);
          }),

          _buildInfoGroup('Откуда пришел клиент', [
            _buildInfoRow(null, _contactData!['source']?.toString().isNotEmpty == true ? _contactData!['source'] : 'Нет данных'),
          ]),

          _buildInfoGroup('Сведения о работе', [
            _buildInfoRow('Место работы', _contactData!['jobPlace']?.toString().isNotEmpty == true ? _contactData!['jobPlace'] : 'Нет данных'),
            _buildInfoRow('Отдел', _contactData!['department']?.toString().isNotEmpty == true ? _contactData!['department'] : 'Нет данных'),
            _buildInfoRow('Профессия', _contactData!['profession']?.toString().isNotEmpty == true ? _contactData!['profession'] : 'Нет данных'),
          ]),

          _buildInfoGroup('Адрес', [
            _buildInfoRow(null, _contactData!['address']?.toString().isNotEmpty == true ? _contactData!['address'] : 'Нет данных'),
          ]),

          _buildInfoGroup('Ссылки', [
            _buildInfoRow(null, _contactData!['link'] ?? 'Нет данных', isLink: true),
          ]),

          _buildInfoGroup('Заметки', [
            _buildInfoRow(null, _contactData!['description']?.toString().isNotEmpty == true ? _contactData!['description'] : 'Нет данных'),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoGroup(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...rows,
      ],
    );
  }

  Widget _buildInfoRow(String? label, String value, {bool isLink = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              label,
              style: const TextStyle(
                color: Color(0x993C3C43),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: isLink ? const Color(0xFF007AFF) : Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = 0),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedSegment == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Посещения',
                  style: TextStyle(
                    color: _selectedSegment == 0 ? const Color(0xFFFA4E02) : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = 1),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedSegment == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Файлы',
                  style: TextStyle(
                    color: _selectedSegment == 1 ? const Color(0xFFFA4E02) : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'События и посещения',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          StreamBuilder<List<CalendarEvent>>(
            stream: _firestoreService.getEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Нет запланированных событий', style: TextStyle(color: Colors.grey)),
                );
              }

              // Фильтруем события, где в selectedContacts есть текущий контакт
              final contactEvents = snapshot.data!.where((event) {
                final contacts = event.selectedContacts as List<Map<String, dynamic>>? ?? [];
                return contacts.any((c) => c['id'] == widget.contactId);
              }).toList();

              if (contactEvents.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('События не найдены', style: TextStyle(color: Colors.grey)),
                );
              }

              return Column(
                children: contactEvents.map((event) {
                  // Форматируем дату (можете добавить intl для лучшего формата)
                  final date = event.startTime;
                  final dateString = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                  
                  return _buildVisitItem(
                    event.title.isNotEmpty ? event.title : 'Событие без названия',
                    '${event.type ?? 'Тип не указан'} • $dateString',
                    onTap: () {
                      if (kIsWeb || MediaQuery.of(context).size.width > 800) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              width: 600,
                              height: 800,
                              child: EventDetailPage(
                                event: event, 
                                isEmbedded: true, 
                                onBack: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
                        );
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  Widget _buildVisitItem(String title, String subtitle, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today, color: Color(0xFF007AFF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0088FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0x993C3C43),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
