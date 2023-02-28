import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static Future<bool> saveString(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
      return prefs.setString(key, value);
  }

  static Future<bool> saveMap(String key, Map<String, dynamic> value) async {
    return saveString(key, jsonEncode(value));
  }

  static Future<String> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  static Future<Map<String, dynamic>> getMap(String key) async {
    try {
      return jsonDecode(await getString(key));
    } catch (e) {
      return {};
    }
  }

  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}