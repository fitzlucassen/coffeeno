import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/coffee.dart';
import 'coffee_repository.dart';

/// Schedules a single local push notification per coffee when it approaches
/// the end of its peak-freshness window (peakEndDays - 2 from roast date).
class FreshnessNotificationService {
  FreshnessNotificationService({required this.coffeeRepository});

  final CoffeeRepository coffeeRepository;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelId = 'freshness_reminders';
  static const _channelName = 'Freshness Reminders';
  static const _channelDescription =
      'Reminds you to brew your coffee before it passes peak freshness';

  /// Must be called once before scheduling. Safe to call multiple times.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Requests notification permission on Android 13+. Returns true if granted.
  Future<bool> _requestAndroidPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;

    final granted = await android.requestNotificationsPermission();
    if (granted != true) {
      debugPrint('[COFFEENO] Notification permission denied');
      return false;
    }

    // Also request exact-alarm permission for scheduled notifications.
    final exactAlarm = await android.requestExactAlarmsPermission();
    if (exactAlarm != true) {
      debugPrint('[COFFEENO] Exact alarm permission denied');
      // We can still fall back to inexact scheduling, so don't block.
    }

    return true;
  }

  /// Schedules a freshness notification for [coffee].
  ///
  /// Skips if:
  /// - roastDate is null
  /// - freshnessNotified is already true
  /// - the reminder date is in the past
  ///
  /// On success, sets `freshnessNotified = true` in Firestore.
  Future<void> scheduleForCoffee(Coffee coffee) async {
    if (coffee.roastDate == null) return;
    if (coffee.freshnessNotified) return;

    // "Use soon" starts at peakEndDays; we notify 2 days before that.
    final reminderDate =
        coffee.roastDate!.add(Duration(days: coffee.peakEndDays - 2));
    final now = DateTime.now();

    if (reminderDate.isBefore(now)) {
      debugPrint(
          '[COFFEENO] Freshness reminder date already passed for ${coffee.id}');
      return;
    }

    final permissionGranted = await _requestAndroidPermission();
    if (!permissionGranted) return;

    final notificationId = coffee.id.hashCode;

    final body = coffee.roaster.isNotEmpty
        ? 'Your ${coffee.name} from ${coffee.roaster} is leaving peak freshness — brew it soon!'
        : 'Your ${coffee.name} is leaving peak freshness — brew it soon!';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.defaultPriority,
    );

    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final scheduledDate = tz.TZDateTime.from(reminderDate, tz.local);

    await _plugin.zonedSchedule(
      notificationId,
      'Time to brew!',
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint(
        '[COFFEENO] Scheduled freshness notification for ${coffee.id} at $scheduledDate');

    // Mark as notified so we don't schedule again.
    await coffeeRepository.updateCoffee(
      coffee.copyWith(freshnessNotified: true),
    );
  }

  /// Cancels a pending notification for a coffee (e.g. when deleted).
  Future<void> cancelForCoffee(String coffeeId) async {
    final notificationId = coffeeId.hashCode;
    await _plugin.cancel(notificationId);
    debugPrint('[COFFEENO] Cancelled freshness notification for $coffeeId');
  }

  /// Reschedules notifications for all coffees that haven't been notified yet.
  /// Intended to be called on app start after login.
  Future<void> rescheduleAll(List<Coffee> coffees) async {
    for (final coffee in coffees) {
      try {
        await scheduleForCoffee(coffee);
      } catch (e) {
        debugPrint(
            '[COFFEENO] Failed to schedule notification for ${coffee.id}: $e');
      }
    }
  }
}
