import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationSettings {
  static const _general = "notif_general";
  static const _sound = "notif_sound";
  static const _dnd = "notif_dnd";
  static const _vibrate = "notif_vibrate";
  static const _lockscreen = "notif_lockscreen";
  static const _reminders = "notif_reminders";

  static Future saveSettings({
    required bool general,
    required bool sound,
    required bool dnd,
    required bool vibrate,
    required bool lockscreen,
    required bool reminders,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_general, general);
    await prefs.setBool(_sound, sound);
    await prefs.setBool(_dnd, dnd);
    await prefs.setBool(_vibrate, vibrate);
    await prefs.setBool(_lockscreen, lockscreen);
    await prefs.setBool(_reminders, reminders);
  }

  static Future<Map<String, bool>> load() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "general": prefs.getBool(_general) ?? true,
      "sound": prefs.getBool(_sound) ?? true,
      "dnd": prefs.getBool(_dnd) ?? false,
      "vibrate": prefs.getBool(_vibrate) ?? true,
      "lockscreen": prefs.getBool(_lockscreen) ?? true,
      "reminders": prefs.getBool(_reminders) ?? true,
    };
  }
}
