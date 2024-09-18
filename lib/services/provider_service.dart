import 'package:cow_monitor/services/cow_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/cow_repository.dart';

class CowProvider with ChangeNotifier {
  // Cow selection states
  Cow? _selectedCow;
  int? _selectedCowId;
  DateTime? _startTimestamp;
  DateTime? _endTimestamp;
  
  // Empty list of cows from the repository
  List<Cow> _cows = [];
  
  List<Map<String, dynamic>> _cowPath = [];

  final CowService _cowService = CowService();
  final CowRepository _cowRepository = CowRepository();

  // Notification settings
  bool _notificationsEnabled = true;
  bool _alertsEnabled = true;
  bool _messagesEnabled = true;
  bool _remindersEnabled = false;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _pushNotifications = false;

  // Dark mode and stream URLs
  bool _isDarkMode = false;

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

  Future<void> loadCowData(int startTime, int endTime) async {
    if (_selectedCowId == null) return;
    // final activities =
    //     await cowRepository.fetchCowData(startTime, endTime, _selectedCowId!);
    final cowData = await _cowService.fetchCowsDataForSelectedCow(
      selectedCowId!,
      DateTime.fromMillisecondsSinceEpoch(startTime * 1000),
      DateTime.fromMillisecondsSinceEpoch(endTime * 1000),
    );

    _cowPath = cowData
        .map((cow) =>
            {'position': Vector3(cow.x, cow.y, 0), 'timestamp': cow.timestamp})
        .toList();

    notifyListeners();
  }

  // Getter for the cow path
  List<Map<String, dynamic>> get cowPaths => _cowPath;

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (_selectedCowId != null) {
      await pref.setInt('selectedCowId', _selectedCowId!);
    }
    if (_startTimestamp != null) {
      await pref.setString(
          'startTimestamp', _startTimestamp!.toIso8601String());
    }
    if (_endTimestamp != null) {
      await pref.setString('endTimestamp', _endTimestamp!.toIso8601String());
    }

    await pref.setBool('notificationsEnabled', _notificationsEnabled);
    await pref.setBool('alertsEnabled', _alertsEnabled);
    await pref.setBool('messagesEnabled', _messagesEnabled);
    await pref.setBool('remindersEnabled', _remindersEnabled);
    await pref.setBool('isDarkMode', _isDarkMode);
    // await pref.setString('currentStreamUrl', _currentStreamUrl);
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
    _saveSettings();
    notifyListeners();
  }

  void setSelectedTimeRange(DateTime start, DateTime end) {
    _startTimestamp = start;
    _endTimestamp = end;
    _saveSettings();
    notifyListeners();
  }

  int get currentTimestamp {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  Future<void> getCowMovement(int startTime, int endTime, int objectId) async {
    try {
      _cows = await _cowRepository.fetchCowData(startTime, endTime, objectId);
      notifyListeners();
    } catch (e) {
      print('Error fetching cow data: $e');
    }
  }

  Future<List<Cow>> getCowMovementByAction(String action) async {
    return _cows.where((movement)=>movement.action == action).toList();
  }

  void clearSelection() {
    _selectedCow = null;
    _selectedCowId = null;
    _startTimestamp = null;
    _endTimestamp = null;
    _saveSettings();
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
}
