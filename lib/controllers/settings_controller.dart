import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsController extends ChangeNotifier {
  AppSettings _settings = AppSettings();

  bool get isDarkMode => _settings.isDarkMode;
  bool get notificationsEnabled => _settings.notificationsEnabled;

  SettingsController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = await StorageService.getAppSettings();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _settings.isDarkMode = !_settings.isDarkMode;
    await _saveSettings();
  }

  Future<void> toggleNotifications() async {
    _settings.notificationsEnabled = !_settings.notificationsEnabled;
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    await StorageService.saveAppSettings(_settings);
    notifyListeners();
  }
}
