import 'package:flutter/material.dart';
import 'package:business_calendar/core/services/firestore_service.dart';

class ContactSelectionPage extends StatefulWidget {
  final List<String> initialSelectedIds;

  const ContactSelectionPage({
    super.key,
    this.initialSelectedIds = const [],
  });

  @override
  State<ContactSelectionPage> createState() => _ContactSelectionPageState();
}

class _ContactSelectionPageState extends State<ContactSelectionPage> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final List<Map<String, dynamic>> _selectedContacts = [];
  
  List<Map<String, dynamic>> _allContacts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.initialSelectedIds);
    _loadContacts();
  }

  void _loadContacts() {
    _firestoreService.getContacts().listen((contacts) {
      if (mounted) {
        setState(() {
          _allContacts = contacts;
          // Sync selected contacts data
          _selectedContacts.clear();
          for (var id in _selectedIds) {
            final contact = _allContacts.firstWhere((c) => c['id'] == id, orElse: () => {});
            if (contact.isNotEmpty) _selectedContacts.add(contact);
          }
        });
      }
    });
  }

  void _toggleSelection(Map<String, dynamic> contact) {
    final id = contact['id'] as String;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        _selectedContacts.removeWhere((c) => c['id'] == id);
      } else {
        _selectedIds.add(id);
        _selectedContacts.add(contact);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var filteredContacts = _allContacts.where((contact) {
      final name = (contact['name'] as String? ?? '').toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    // Group by first letter
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var contact in filteredContacts) {
      final name = contact['name'] as String? ?? 'Без имени';
      final letter = name.isNotEmpty ? name[0].toUpperCase() : '#';
      grouped.putIfAbsent(letter, () => []).add(contact);
    }
    final sortedLetters = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Отмена',
            softWrap: false,
            style: TextStyle(color: Color(0xFF007AFF), fontSize: 17),
          ),
        ),
        leadingWidth: 100,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedContacts),
            child: const Text(
              'Готово',
              style: TextStyle(color: Color(0xFF007AFF), fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        centerTitle: true,
        title: const Text('Контакты', style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600)),
        shape: const Border(bottom: BorderSide(color: Color(0x4C3C3C43), width: 0.33)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0x993C3C43), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Поиск',
                        hintStyle: TextStyle(color: Color(0x993C3C43), fontSize: 17),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sortedLetters.length,
              itemBuilder: (context, index) {
                final letter = sortedLetters[index];
                final contacts = grouped[letter]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        letter,
                        style: const TextStyle(color: Color(0xFFFA4E02), fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: contacts.asMap().entries.map((entry) {
                          final i = entry.key;
                          final contact = entry.value;
                          final id = contact['id'] as String;
                          final isSelected = _selectedIds.contains(id);
                          final name = contact['name'] ?? 'Без имени';
                          final photoUrl = contact['photoUrl'] as String?;

                          return Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0x0F0088FF),
                                    shape: BoxShape.circle,
                                    image: photoUrl != null ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover) : null,
                                  ),
                                  child: photoUrl == null 
                                    ? Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF0088FF), fontSize: 16, fontWeight: FontWeight.w500)))
                                    : null,
                                ),
                                title: Text(name, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400)),
                                trailing: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFFA4E02) : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFFA4E02) : const Color(0x4C3C3C43),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                ),
                                onTap: () => _toggleSelection(contact),
                              ),
                              if (i < contacts.length - 1)
                                const Divider(height: 1, indent: 72, endIndent: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
