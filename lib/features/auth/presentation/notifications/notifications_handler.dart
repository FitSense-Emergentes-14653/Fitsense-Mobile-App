import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required bool sound,
    required bool vibrate,
    required bool lockscreen,
  }) async {

    final androidDetails = AndroidNotificationDetails(
      "fitsense_channel",
      "FitSense Notifications",
      importance: Importance.high,
      priority: Priority.high,
      playSound: sound,
      enableVibration: false,
      vibrationPattern: null,
      visibility: lockscreen
          ? NotificationVisibility.public
          : NotificationVisibility.secret,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
