import 'package:flutter/material.dart';
import 'add_contact_page.dart';

class ContactListPage extends StatelessWidget {
  const ContactListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок
            _buildAppBar(),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 12),
                  // Группа А
                  _buildContactGroup('А', [
                    _ContactItem(name: 'контакт А', hasImage: false, initial: 'A'),
                    _ContactItem(name: 'контакт А', hasImage: true),
                  ]),
                  
                  const SizedBox(height: 20),
                  // Группа Б
                  _buildContactGroup('Б', [
                    _ContactItem(name: 'контакт А', hasImage: false, initial: 'Б'),
                    _ContactItem(name: 'контакт А', hasImage: true),
                    _ContactItem(name: 'контакт А', hasImage: false, initial: 'Б'),
                  ]),
                  
                  const SizedBox(height: 20),
                  // Группа В
                  _buildContactGroup('В', [
                    _ContactItem(name: 'контакт А', hasImage: true),
                    _ContactItem(name: 'контакт А', hasImage: false, initial: 'В'),
                  ]),
                  
                  const SizedBox(height: 20),
                  // Группа Г
                  _buildContactGroup('Г', [
                    _ContactItem(name: 'контакт А', hasImage: false, initial: 'Г'),
                    _ContactItem(name: 'контакт А', hasImage: true),
                  ]),
                  
                  const SizedBox(height: 100), // Отступ под FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
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
            onPressed: () {},
            icon: const Icon(Icons.search, color: Color(0xFF1C1B1F), size: 24),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1C1B1F), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildContactGroup(String letter, List<_ContactItem> contacts) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок группы (Буква)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              letter,
              style: const TextStyle(
                color: Color(0xFFFA4E02),
                fontSize: 17,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Список контактов в группе
          ...contacts.asMap().entries.map((entry) {
            final index = entry.key;
            final contact = entry.value;
            return Column(
              children: [
                _buildContactTile(contact),
                if (index < contacts.length - 1)
                  const Divider(height: 1, indent: 72, endIndent: 16, color: Color(0xFFF2F2F7)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactTile(_ContactItem contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Аватар
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: contact.hasImage ? null : const Color(0x0F0088FF),
              shape: BoxShape.circle,
              image: contact.hasImage 
                ? const DecorationImage(
                    image: NetworkImage("https://placehold.co/40x40"),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            child: contact.hasImage 
              ? null 
              : Center(
                  child: Text(
                    contact.initial ?? '',
                    style: const TextStyle(
                      color: Color(0xFF0088FF),
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
          ),
          const SizedBox(width: 16),
          // Имя
          Expanded(
            child: Text(
              contact.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddContactPage(),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFA4E02),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFA4E02).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}

class _ContactItem {
  final String name;
  final bool hasImage;
  final String? initial;

  _ContactItem({
    required this.name,
    required this.hasImage,
    this.initial,
  });
}
