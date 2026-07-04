import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/coffee.dart';
import 'coffee_repository.dart';

/// Builds the localized freshness-reminder body for [coffee], choosing the
/// with/without-roaster phrasing. Shared by the screens that schedule reminders
/// so the copy lives in one place.
String freshnessNotificationBody(AppLocalizations l10n, Coffee coffee) {
  return coffee.roaster.isNotEmpty
      ? l10n.freshnessNotificationBody(coffee.name, coffee.roaster)
      : l10n.freshnessNotificationBodyNoRoaster(coffee.name);
}

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

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
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
  /// On success, sets `freshnessNotified = true` in Firestore. [title] and
  /// [body] provide localized copy; [body] receives the coffee and returns the
  /// message text.
  Future<void> scheduleForCoffee(
    Coffee coffee, {
    String? title,
    String Function(Coffee coffee)? body,
  }) async {
    if (coffee.roastDate == null) return;
    if (coffee.freshnessNotified) return;

    // "Use soon" starts at peakEndDays; we notify 2 days before that.
    final reminderDate = coffee.roastDate!.add(
      Duration(days: coffee.peakEndDays - 2),
    );
    final now = DateTime.now();

    if (reminderDate.isBefore(now)) {
      debugPrint(
        '[COFFEENO] Freshness reminder date already passed for ${coffee.id}',
      );
      return;
    }

    final permissionGranted = await _requestAndroidPermission();
    if (!permissionGranted) return;

    final notificationId = _notificationIdFor(coffee.id);

    // Fall back to English when the caller didn't supply localized copy (e.g. a
    // background reschedule without a BuildContext).
    final resolvedTitle = title ?? 'Time to brew!';
    final resolvedBody =
        body?.call(coffee) ??
        (coffee.roaster.isNotEmpty
            ? 'Your ${coffee.name} from ${coffee.roaster} is leaving peak freshness — brew it soon!'
            : 'Your ${coffee.name} is leaving peak freshness — brew it soon!');

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
      resolvedTitle,
      resolvedBody,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint(
      '[COFFEENO] Scheduled freshness notification for ${coffee.id} at $scheduledDate',
    );

    // Mark as notified so we don't schedule again. Use the targeted field
    // update (not a full-document write) so this can't clobber a concurrent
    // partial write such as background AI enrichment.
    await coffeeRepository.markFreshnessNotified(coffee.id);
  }

  /// Cancels a pending notification for a coffee (e.g. when deleted).
  Future<void> cancelForCoffee(String coffeeId) async {
    await _plugin.cancel(_notificationIdFor(coffeeId));
    debugPrint('[COFFEENO] Cancelled freshness notification for $coffeeId');
  }

  /// Derives a stable, non-negative 31-bit notification id from a coffee's
  /// document id via FNV-1a. Dart's `String.hashCode` is not stable across
  /// isolates/runs and can be negative, so two coffees could share a slot and
  /// silently overwrite/cancel each other's reminder.
  int _notificationIdFor(String coffeeId) {
    var hash = 0x811c9dc5; // FNV offset basis (32-bit)
    for (final codeUnit in coffeeId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff; // FNV prime, keep 32-bit
    }
    return hash & 0x7fffffff; // mask to a non-negative 31-bit int
  }

  /// Reschedules notifications for all coffees that haven't been notified yet.
  /// Intended to be called on app start after login. [title]/[body] carry the
  /// localized copy forwarded to [scheduleForCoffee].
  Future<void> rescheduleAll(
    List<Coffee> coffees, {
    String? title,
    String Function(Coffee coffee)? body,
  }) async {
    for (final coffee in coffees) {
      try {
        await scheduleForCoffee(coffee, title: title, body: body);
      } catch (e) {
        debugPrint(
          '[COFFEENO] Failed to schedule notification for ${coffee.id}: $e',
        );
      }
    }
  }
}
