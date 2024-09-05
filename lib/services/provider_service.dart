import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cow_repository.dart';

class CowProvider with ChangeNotifier {
  // Cow selection states
  Cow? _selectedCow;
  int? _selectedCowId;
  DateTime? _startTimestamp;
  DateTime? _endTimestamp;

  // Notification settings
  bool _notificationsEnabled = true;
  bool _alertsEnabled = true;
  bool _messagesEnabled = true;
  bool _remindersEnabled = false;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _pushNotifications = false;

  // Dark mode and stream URL
  bool _isDarkMode = false;
  String _currentStreamUrl = 'http://140.116.86.242:25582/stream_video';

  // Getters for cow selection
  Cow? get selectedCow => _selectedCow;
  int? get selectedCowId => _selectedCowId;
  DateTime? get startTimestamp => _startTimestamp;
  DateTime? get endTimestamp => _endTimestamp;

  // Getters for notification settings
  bool get notificationsEnabled => _notificationsEnabled;
  bool get alertsEnabled => _alertsEnabled;
  bool get messagesEnabled => _messagesEnabled;
  bool get remindersEnabled => _remindersEnabled;
  bool get isDarkMode => _isDarkMode;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;
  bool get pushNotifications => _pushNotifications;
  String get currentStreamUrl => _currentStreamUrl;

  CowProvider() {
    _loadSettings(); // Load settings on initialization
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _notificationsEnabled = pref.getBool('notificationsEnabled') ?? true;
    _alertsEnabled = pref.getBool('alertsEnabled') ?? true;
    _messagesEnabled = pref.getBool('messagesEnabled') ?? true;
    _remindersEnabled = pref.getBool('remindersEnabled') ?? false;
    _isDarkMode = pref.getBool('isDarkMode') ?? false;
    _currentStreamUrl = pref.getString('currentStreamUrl') ??
        'http://140.116.86.242:25582/stream_video';
    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('notificationsEnabled', _notificationsEnabled);
    await pref.setBool('alertsEnabled', _alertsEnabled);
    await pref.setBool('messagesEnabled', _messagesEnabled);
    await pref.setBool('remindersEnabled', _remindersEnabled);
    await pref.setBool('isDarkMode', _isDarkMode);
    await pref.setString('currentStreamUrl', _currentStreamUrl);
  }

  Future<void> _saveNotificationSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('emailNotifications', _emailNotifications);
    await pref.setBool('smsNotifications', _smsNotifications);
    await pref.setBool('pushNotifications', _pushNotifications);
  }

  // Cow selection methods
  void selectCow(Cow cow, int cowId) {
    _selectedCow = cow;
    _selectedCowId = cowId;
    notifyListeners();
  }

  void setSelectedTimeRange(DateTime start, DateTime end) {
    _startTimestamp = start;
    _endTimestamp = end;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCow = null;
    _selectedCowId = null;
    _startTimestamp = null;
    _endTimestamp = null;
    notifyListeners();
  }

  // Notification settings methods
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void toggleAlerts(bool value) {
    _alertsEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void toggleMessages(bool value) {
    _messagesEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void toggleReminders(bool value) {
    _remindersEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    _saveSettings();
    notifyListeners();
  }

  void toggleEmailNotifications(bool value) {
    _emailNotifications = value;
    _saveNotificationSettings();
    notifyListeners();
  }

  void toggleSmsNotifications(bool value) {
    _smsNotifications = value;
    _saveNotificationSettings();
    notifyListeners();
  }

  void togglePushNotifications(bool value) {
    _pushNotifications = value;
    _saveNotificationSettings();
    notifyListeners();
  }

  void setCurrentStreamUrl(String url) {
    _currentStreamUrl = url;
    _saveSettings();
    notifyListeners();
  }
}
