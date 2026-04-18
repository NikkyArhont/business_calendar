import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _firstTimeKey = 'is_first_time';
  
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  static Future<void> setFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, value);
  }
}

