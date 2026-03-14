import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for managing break reminder notifications.
/// 
/// Provides two types of notifications:
/// 1. Periodic break reminders while clocked in (every X minutes from API)
/// 2. Extended break warning when on break for more than 15 minutes
class BreakReminderService {
  static final BreakReminderService _instance = BreakReminderService._internal();
  factory BreakReminderService() => _instance;
  BreakReminderService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _breakReminderTimer;
  Timer? _extendedBreakTimer;
  bool _isInitialized = false;
  
  // Notification IDs for break reminders
  static const int _breakReminderId = 9001;
  static const int _extendedBreakId = 9002;
  
  // Extended break warning threshold in minutes (configurable from API break_duration)
  int _extendedBreakThresholdMinutes = 15;

  /// Initialize the notification service and create the Android channel.
  Future<void> init() async {
    if (_isInitialized) return;
    
    debugPrint('🔧 Initializing BreakReminderService...');
    
    // Create the Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'break_reminder_channel',
      'Break Reminders',
      description: 'Reminds you to take breaks while working',
      importance: Importance.high,
      playSound: true,
    );
    
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    _isInitialized = true;
    debugPrint('✅ BreakReminderService initialized');
  }

  /// Set the extended break threshold from API's break_duration.
  void setExtendedBreakThreshold(int minutes) {
    if (minutes > 0) {
      _extendedBreakThresholdMinutes = minutes;
      debugPrint('⏱️ Extended break threshold set to $minutes minutes');
    }
  }

  /// Start periodic break reminders.
  /// 
  /// [intervalMinutes] - How often to remind the user to take a break.
  /// Typically this comes from the API's `alloted_break_time` or `breaks_in_minutes`.
  void startBreakReminder(int intervalMinutes) {
    // Cancel any existing timer
    stopBreakReminder();
    
    if (intervalMinutes <= 0) {
      debugPrint('⚠️ Invalid break interval: $intervalMinutes. Using default 15 minutes.');
      intervalMinutes = 15;
    }
    
    debugPrint('🔔 Starting break reminders every $intervalMinutes minutes');
    
    // Create periodic timer
    _breakReminderTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (timer) {
        _showBreakReminderNotification();
      },
    );
  }

  /// Stop break reminder timer.
  void stopBreakReminder() {
    if (_breakReminderTimer != null) {
      _breakReminderTimer?.cancel();
      _breakReminderTimer = null;
      debugPrint('🔕 Stopped break reminder timer');
    }
  }

  /// Start extended break warning timer.
  /// Called when user starts a break.
  void startExtendedBreakWarning() {
    // Cancel any existing extended break timer
    cancelExtendedBreakWarning();
    
    debugPrint('⏱️ Starting extended break warning timer ($_extendedBreakThresholdMinutes minutes)');
    
    // Schedule notification after threshold
    _extendedBreakTimer = Timer(
      Duration(minutes: _extendedBreakThresholdMinutes),
      () {
        _showExtendedBreakNotification();
      },
    );
  }

  /// Cancel extended break warning timer.
  /// Called when user ends a break or clocks out.
  void cancelExtendedBreakWarning() {
    if (_extendedBreakTimer != null) {
      _extendedBreakTimer?.cancel();
      _extendedBreakTimer = null;
      debugPrint('🔕 Cancelled extended break warning timer');
    }
  }

  /// Show break reminder notification.
  Future<void> _showBreakReminderNotification() async {
    debugPrint('🔔 Showing break reminder notification');
    
    try {
      await _localNotificationsPlugin.show(
        _breakReminderId,
        'Time for a Break! ☕',
        'You\'ve been working hard. Take a short break to recharge.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'break_reminder_channel',
            'Break Reminders',
            channelDescription: 'Reminds you to take breaks while working',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error showing break reminder notification: $e');
    }
  }

  /// Show extended break warning notification.
  Future<void> _showExtendedBreakNotification() async {
    debugPrint('⚠️ Showing extended break warning notification');
    
    try {
      await _localNotificationsPlugin.show(
        _extendedBreakId,
        'Break Time Exceeded ⏰',
        'You\'ve been on break for over $_extendedBreakThresholdMinutes minutes. Time to get back to work!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'break_reminder_channel',
            'Break Reminders',
            channelDescription: 'Reminds you to take breaks while working',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error showing extended break notification: $e');
    }
  }

  /// Cancel all notifications and timers.
  void dispose() {
    stopBreakReminder();
    cancelExtendedBreakWarning();
    
    // Also cancel any shown notifications
    _localNotificationsPlugin.cancel(_breakReminderId);
    _localNotificationsPlugin.cancel(_extendedBreakId);
    
    debugPrint('🧹 BreakReminderService disposed');
  }
}
