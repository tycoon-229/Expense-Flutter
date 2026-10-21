import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyReminderService {
  static final DailyReminderService _instance = DailyReminderService._internal();
  factory DailyReminderService() => _instance;
  DailyReminderService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String _prefEnabledKey = 'daily_reminder_enabled';
  static const String _prefHourKey = 'daily_reminder_hour';
  static const String _prefMinuteKey = 'daily_reminder_minute';

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(initSettings);

    // Xin quyền thông báo trên Android 13+
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    // Khởi tạo lịch nếu người dùng đã bật trước đó
    final settings = await getReminderSettings();
    if (settings['isEnabled'] == true) {
      await scheduleDailyReminder(
        hour: settings['hour'] as int,
        minute: settings['minute'] as int,
        isEnabled: true,
      );
    }
  }

  Future<Map<String, dynamic>> getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_prefEnabledKey) ?? true; // Mặc định bật
    final hour = prefs.getInt(_prefHourKey) ?? 20; // Mặc định 20h00
    final minute = prefs.getInt(_prefMinuteKey) ?? 0;
    return {
      'isEnabled': isEnabled,
      'hour': hour,
      'minute': minute,
    };
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required bool isEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabledKey, isEnabled);
    await prefs.setInt(_prefHourKey, hour);
    await prefs.setInt(_prefMinuteKey, minute);

    // Hủy lịch cũ trước khi đặt mới
    await _notificationsPlugin.cancel(1001);

    if (!isEnabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_expense_reminder_channel',
      'Nhắc nhở ghi chép chi tiêu',
      channelDescription: 'Kênh thông báo nhắc nhở cập nhật thu chi mỗi ngày',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        1001,
        '⏰ Đã đến lúc kiểm tra chi tiêu!',
        'Hôm nay bạn có khoản thu hay chi tiêu nào không? Dành 1 phút để cập nhật ngay nhé!',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Lặp lại mỗi ngày
      );
    } catch (_) {
      // Fallback nếu thiết bị không hỗ trợ exact alarm
    }
  }

  /// Hiển thị thông báo kiểm tra ngay lập tức
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_expense_reminder_channel',
      'Nhắc nhở ghi chép chi tiêu',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notificationsPlugin.show(
      1002,
      '🔔 Nhắc nhở ghi chép thu chi',
      'Đừng quên ghi lại các khoản chi tiêu hôm nay để kiểm soát tài chính tốt hơn!',
      const NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails()),
    );
  }
}
