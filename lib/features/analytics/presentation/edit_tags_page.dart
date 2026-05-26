import 'package:flutter/material.dart';

class EditTagsPage extends StatefulWidget {
  final String title;
  final List<String> availableTags;

  const EditTagsPage({
    super.key,
    required this.title,
    required this.availableTags,
  });

  @override
  State<EditTagsPage> createState() => _EditTagsPageState();
}

class _EditTagsPageState extends State<EditTagsPage> {
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.availableTags);
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        String newTag = '';
        return AlertDialog(
          title: const Text('Добавить тег'),
          content: TextField(
            onChanged: (value) => newTag = value,
            decoration: const InputDecoration(hintText: "Название тега"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (newTag.isNotEmpty) {
                  setState(() => _tags.add(newTag));
                }
                Navigator.pop(context);
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF), size: 22),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _tags),
                  child: const Text(
                    'Готово',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 17,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Выберите тег',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              // Кнопка Добавить тег
              GestureDetector(
                onTap: _addTag,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9EFE9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Color(0xFFFA4E02), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Добавить тег',
                        style: TextStyle(
                          color: Color(0xFFFA4E02),
                          fontSize: 17,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Список тегов с удалением
              ...List.generate(_tags.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.label, color: Color(0xFFFA4E02), size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _tags[index],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _tags.removeAt(index)),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.red, size: 20),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          // Кнопка Сохранить
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _tags),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFA4E02),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Сохранить',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontFamily: 'Inter',
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
}
