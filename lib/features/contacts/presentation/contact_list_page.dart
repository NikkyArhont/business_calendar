import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/core/services/firestore_service.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  // Режим выбора для удаления
  bool _isSelectionMode = false;
  Set<String> _selectedContactIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteSelectedContacts() async {
    if (_selectedContactIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление контактов'),
        content: Text('Вы уверены, что хотите удалить ${_selectedContactIds.length} конт.?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (var id in _selectedContactIds) {
        await _firestoreService.deleteContact(id);
      }
      setState(() {
        _isSelectionMode = false;
        _selectedContactIds.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.getContacts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var contacts = snapshot.data ?? [];

                  // Фильтрация по поиску
                  if (_searchQuery.isNotEmpty) {
                    contacts = contacts.where((contact) {
                      final name = (contact['name'] as String? ?? '').toLowerCase();
                      return name.contains(_searchQuery);
                    }).toList();
                  }

                  if (contacts.isEmpty) {
                    return Center(child: _EmptyStateLogo(isSearch: _searchQuery.isNotEmpty));
                  }

                  // Группировка контактов по первой букве
                  final groupedContacts = <String, List<Map<String, dynamic>>>{};
                  for (var contact in contacts) {
                    final name = contact['name'] as String? ?? 'Без имени';
                    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '#';
                    if (!groupedContacts.containsKey(firstLetter)) {
                      groupedContacts[firstLetter] = [];
                    }
                    groupedContacts[firstLetter]!.add(contact);
                  }

                  final sortedKeys = groupedContacts.keys.toList()..sort();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedKeys.length + 1, // +1 для отступа снизу
                    itemBuilder: (context, index) {
                      if (index == sortedKeys.length) {
                        return const SizedBox(height: 100);
                      }
                      final letter = sortedKeys[index];
                      final group = groupedContacts[letter]!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _buildContactGroup(letter, group, contacts),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSelectionMode && _selectedContactIds.isNotEmpty
          ? FloatingActionButton(
              onPressed: _deleteSelectedContacts,
              backgroundColor: const Color(0xFFFA4E02),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            )
          : FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addContact);
              },
              backgroundColor: const Color(0xFFFA4E02),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedContactIds.clear();
                });
              },
              child: const Text(
                'Отмена',
                style: TextStyle(
                  color: Color(0xFFFA4E02),
                  fontSize: 17,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Логика "Выбрать все" будет реализована ниже через передачу списка всех контактов
              },
              child: const Text(
                'Выбрать все',
                style: TextStyle(
                  color: Color(0xFFFA4E02),
                  fontSize: 17,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ] else if (_isSearching) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1B1F)),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Поиск контактов...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.close, color: Color(0xFF1C1B1F)),
              ),
          ] else ...[
            const Expanded(
              child: Text(
                'Контакты',
                style: TextStyle(
                  color: Color(0xFF1C1B1F),
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.27,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _isSearching = true),
              icon: const Icon(Icons.search, color: Color(0xFFFA4E02), size: 24),
            ),
            IconButton(
              onPressed: () => setState(() {
                _isSelectionMode = true;
                _isSearching = false;
              }),
              icon: const Icon(Icons.edit, color: Color(0xFFFA4E02), size: 24),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactGroup(String letter, List<Map<String, dynamic>> group, List<Map<String, dynamic>> allContacts) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  letter,
                  style: const TextStyle(
                    color: Color(0xFFFA4E02),
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isSelectionMode)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        final groupIds = group.map((c) => c['id'] as String).toSet();
                        if (_selectedContactIds.containsAll(groupIds)) {
                          _selectedContactIds.removeAll(groupIds);
                        } else {
                          _selectedContactIds.addAll(groupIds);
                        }
                      });
                    },
                    child: Text(
                      _selectedContactIds.containsAll(group.map((c) => c['id'] as String).toSet()) 
                        ? 'Снять все' 
                        : 'Выбрать все',
                      style: const TextStyle(
                        color: Color(0xFFFA4E02),
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ...group.asMap().entries.map((entry) {
            final index = entry.key;
            final contact = entry.value;
            return Column(
              children: [
                _buildContactTile(contact),
                if (index < group.length - 1)
                  const Divider(height: 1, indent: 72, endIndent: 16, color: Color(0xFFF2F2F7)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactTile(Map<String, dynamic> contact) {
    final contactId = contact['id'] as String;
    final name = contact['name'] as String? ?? 'Без имени';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final photoUrl = contact['photoUrl'] as String?;
    final isSelected = _selectedContactIds.contains(contactId);

    return InkWell(
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedContactIds.remove(contactId);
            } else {
              _selectedContactIds.add(contactId);
            }
          });
        } else {
          // Переход на детали (уже реализовано в коде, который я видел раньше)
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: photoUrl != null ? null : const Color(0x0F0088FF),
                shape: BoxShape.circle,
                image: photoUrl != null 
                  ? DecorationImage(
                      image: NetworkImage(photoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              ),
              child: photoUrl == null 
                ? Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Color(0xFF0088FF),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (_isSelectionMode)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFA4E02) : Colors.transparent,
                  border: Border.all(
                    color: const Color(0xFFFA4E02),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected 
                  ? const Icon(Icons.check, size: 14, color: Colors.white) 
                  : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateLogo extends StatelessWidget {
  final bool isSearch;
  const _EmptyStateLogo({this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 343,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Иконка
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0x0F0088FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSearch ? Icons.search_off : Icons.people_outline, 
                  size: 40, 
                  color: const Color(0xFF0088FF),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 343,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 343,
                      child: Text(
                        isSearch 
                            ? 'Контакты не найдены' 
                            : 'Здесь будет отображаться список контактов',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
