import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_routes.dart';

class TagSelectionPage extends StatefulWidget {
  final String title;
  final List<String> initialSelectedTags;
  final List<String> availableTags;

  const TagSelectionPage({
    super.key,
    required this.title,
    this.initialSelectedTags = const [],
    this.availableTags = const [],
  });

  @override
  State<TagSelectionPage> createState() => _TagSelectionPageState();
}

class _TagSelectionPageState extends State<TagSelectionPage> {
  late List<String> _selectedTags;
  late List<String> _availableTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.initialSelectedTags);
    _availableTags = List.from(widget.availableTags);
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _navigateToEditTags() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editTags,
      arguments: {
        'title': widget.title,
        'availableTags': _availableTags,
      },
    );

    if (result != null && result is List<String>) {
      setState(() {
        _availableTags = result;
        // Убираем из выбранных те, которые были удалены
        _selectedTags.removeWhere((tag) => !_availableTags.contains(tag));
      });
    }
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
                  onPressed: () => Navigator.pop(context, _selectedTags),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF), size: 22),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _selectedTags),
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
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemCount: _availableTags.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tag = _availableTags[index];
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () => _toggleTag(tag),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF9EFE9) : Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.label,
                        color: Color(0xFFFA4E02),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFFFA4E02) : Colors.black,
                            fontSize: 17,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: GestureDetector(
              onTap: _navigateToEditTags,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9EFE9),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Редактировать',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFA4E02),
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
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
