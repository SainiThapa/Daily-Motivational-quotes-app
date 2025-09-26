import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/notification_service.dart';

class SettingsController with ChangeNotifier {
  AppSettings _settings = AppSettings();
  final NotificationService _notificationService = NotificationService();
  
  bool get isDarkMode => _settings.isDarkMode;
  bool get notificationsEnabled => _settings.notificationsEnabled;

  SettingsController() {
    _loadSettings();
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    await _notificationService.initialize();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('app_settings');
      
      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(settingsMap);
        
        // Check if notifications should be enabled and schedule if needed
        if (_settings.notificationsEnabled) {
          final isScheduled = await _notificationService.isNotificationScheduled();
          if (!isScheduled) {
            await _notificationService.scheduleDaily7AMNotification();
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Use default settings if loading fails
      _settings = AppSettings();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(_settings.toJson());
      await prefs.setString('app_settings', settingsJson);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    _settings.isDarkMode = !_settings.isDarkMode;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleNotifications() async {
    _settings.notificationsEnabled = !_settings.notificationsEnabled;
    
    try {
      if (_settings.notificationsEnabled) {
        await _notificationService.scheduleDaily7AMNotification();
        debugPrint('Daily notifications enabled for 7:00 AM');
      } else {
        await _notificationService.cancelAllNotifications();
        debugPrint('Daily notifications disabled');
      }
    } catch (e) {
      debugPrint('Error handling notification toggle: $e');
      // Revert the setting if notification setup failed
      _settings.notificationsEnabled = !_settings.notificationsEnabled;
    }
    
    notifyListeners();
    await _saveSettings();
  }

  // Method to manually check and reschedule notifications if needed
  Future<void> checkAndRescheduleNotifications() async {
    if (_settings.notificationsEnabled) {
      final isScheduled = await _notificationService.isNotificationScheduled();
      if (!isScheduled) {
        await _notificationService.scheduleDaily7AMNotification();
        debugPrint('Rescheduled daily notifications');
      }
    }
  }
}