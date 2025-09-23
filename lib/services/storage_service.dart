import 'dart:convert';
import '../models/quote_model.dart';
import '../models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _favoritesKey = 'favorite_quotes';
  static const String _settingsKey = 'app_settings';

  static Future<List<Quote>> getFavoriteQuotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson == null) return [];
      
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.map((json) => Quote.fromJson(json)).toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  static Future<void> saveFavoriteQuotes(List<Quote> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String favoritesJson = json.encode(
        favorites.map((quote) => quote.toJson()).toList(),
      );
      await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  static Future<AppSettings> getAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson == null) return AppSettings();
      
      final Map<String, dynamic> settingsMap = json.decode(settingsJson);
      return AppSettings.fromJson(settingsMap);
    } catch (e) {
      print('Error loading settings: $e');
      return AppSettings();
    }
  }

  static Future<void> saveAppSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String settingsJson = json.encode(settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
}
