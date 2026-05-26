import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/core/services/firestore_service.dart';
import 'package:business_calendar/features/contacts/presentation/contact_detail_page.dart';

class AnalyticsResultsPage extends StatefulWidget {
  final Map<String, dynamic> filters;
  final bool isWebModule;

  const AnalyticsResultsPage({
    super.key,
    required this.filters,
    this.isWebModule = false,
  });

  @override
  State<AnalyticsResultsPage> createState() => _AnalyticsResultsPageState();
}

class _AnalyticsResultsPageState extends State<AnalyticsResultsPage> {
  String? _selectedContactId;
  String _searchQuery = '';

  int? _calculateAge(String? birthday) {
    if (birthday == null || birthday.isEmpty) return null;
    try {
      final parts = birthday.split('.');
      if (parts.length == 3) {
        final dob = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        final now = DateTime.now();
        int age = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
          age--;
        }
        return age;
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.getContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F6F2),
            appBar: widget.isWebModule ? null : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF), size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Результаты', style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600)),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final allContacts = snapshot.data ?? [];

        // Filter logic
        final List<Map<String, dynamic>> filteredContacts = allContacts.where((contact) {
          final contactTags = [
            contact['status'] as String?,
            contact['source'] as String?,
            contact['profession'] as String?,
          ].where((t) => t != null && t.isNotEmpty).cast<String>().toList();
          
          final RangeValues? ageRange = widget.filters['ageRange'] as RangeValues?;
          if (ageRange != null) {
            final age = _calculateAge(contact['birthday'] as String?);
            if (age == null || age < ageRange.start || age > ageRange.end) return false;
          }

          final bool isMale = widget.filters['isMaleSelected'] as bool? ?? true;
          final bool isFemale = widget.filters['isFemaleSelected'] as bool? ?? true;
          final gender = contact['gender'] as String?;
          if (!isMale && gender == 'Мужчина') return false;
          if (!isFemale && gender == 'Женщина') return false;

          bool checkTags(String filterKey) {
            final selectedTags = widget.filters[filterKey] as List<String>? ?? [];
            if (selectedTags.isEmpty) return true;
            return selectedTags.any((tag) => contactTags.contains(tag));
          }

          if (!checkTags('statuses')) return false;
          if (!checkTags('sources')) return false;
          
          final String? professionFilter = widget.filters['profession'];
          if (professionFilter != null && professionFilter.isNotEmpty && professionFilter != 'Название профессии') {
            final prof = contact['profession'] as String? ?? '';
            if (!prof.toLowerCase().contains(professionFilter.toLowerCase())) return false;
          }

          if (_searchQuery.isNotEmpty) {
            final name = (contact['name'] as String? ?? '').toLowerCase();
            if (!name.contains(_searchQuery.toLowerCase())) return false;
          }

          return true;
        }).toList();

        if (widget.isWebModule) {
          return _buildWebLayout(filteredContacts);
        }

        return _buildMobileLayout(filteredContacts);
      },
    );
  }

  Widget _buildWebLayout(List<Map<String, dynamic>> filteredContacts) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Contact List)
        Container(
          width: 250,
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFFE6E8EC))),
            color: Colors.white,
          ),
          child: Column(
            children: [
              _buildWebSearchHeader(filteredContacts.length),
              Expanded(
                child: filteredContacts.isEmpty
                    ? _buildEmptyState()
                    : _buildContactList(filteredContacts, isWeb: true),
              ),
            ],
          ),
        ),
        // Right Column (Contact Details)
        Expanded(
          child: Container(
            color: const Color(0xFFF7F6F2),
            child: _selectedContactId != null
                ? ContactDetailPage(
                    contactId: _selectedContactId!,
                    isWebModule: true,
                  )
                : const Center(
                    child: Text(
                      'Выберите контакт для просмотра',
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebSearchHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Поиск',
                hintStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Color(0xFF8E8E93), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Найдено\n$count контактов',
            style: const TextStyle(
              color: Color(0xFFFA4E02),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<Map<String, dynamic>> filteredContacts) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Результаты',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: filteredContacts.isEmpty
          ? _buildEmptyState()
          : _buildContactList(filteredContacts, isWeb: false),
    );
  }

  Widget _buildContactList(List<Map<String, dynamic>> filteredContacts, {required bool isWeb}) {
    // Grouping by letter
    final groupedContacts = <String, List<Map<String, dynamic>>>{};
    for (var contact in filteredContacts) {
      final String name = contact['name'] as String? ?? 'Без имени';
      final String letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
      if (!groupedContacts.containsKey(letter)) {
        groupedContacts[letter] = [];
      }
      groupedContacts[letter]!.add(contact);
    }
    final sortedKeys = groupedContacts.keys.toList()..sort();

    return ListView.builder(
      padding: isWeb ? EdgeInsets.zero : const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, sectionIndex) {
        final letter = sortedKeys[sectionIndex];
        final contactsForLetter = groupedContacts[letter]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: isWeb ? const EdgeInsets.only(left: 16, top: 12, bottom: 8) : const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                letter,
                style: const TextStyle(
                  color: Color(0xFFFA4E02),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...contactsForLetter.map((contact) {
              final String name = contact['name'] as String? ?? 'Без имени';
              final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
              final List<dynamic> phones = contact['phones'] as List<dynamic>? ?? [];
              final String phone = phones.isNotEmpty ? phones.first.toString() : 'Нет телефона';
              final bool isSelected = _selectedContactId == contact['id'];

              if (isWeb) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedContactId = contact['id'];
                    });
                  },
                  child: Container(
                    color: isSelected ? const Color(0xFFF2F2F7) : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5F0FF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Color(0xFF007AFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Mobile card layout
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.contactDetail,
                    arguments: {'contactId': contact['id']},
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F2F7),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Color(0xFFFA4E02),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              phone,
                              style: const TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC)),
                    ],
                  ),
                ),
              );
            }),
            if (isWeb) const Divider(height: 1, color: Color(0xFFE5E5E5)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F5FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off, size: 40, color: Color(0xFF007AFF)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ничего не найдено',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'По заданным параметрам нет контактов. Попробуйте изменить фильтры.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 15,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
