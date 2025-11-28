import 'package:flutter/material.dart';
import 'local_notifications_settings_page.dart';
import 'notifications_handler.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool general = true;
  bool sound = true;
  bool dnd = false;
  bool vibrate = true;    // → ahora solo visual
  bool lockscreen = true;
  bool reminders = true;

  @override
  void initState() {
    super.initState();
    _loadLocalSettings();
  }

  Future<void> _loadLocalSettings() async {
    final settings = await LocalNotificationSettings.load();

    setState(() {
      general = settings["general"]!;
      sound = settings["sound"]!;
      dnd = settings["dnd"]!;
      vibrate = settings["vibrate"]!;
      lockscreen = settings["lockscreen"]!;
      reminders = settings["reminders"]!;
    });
  }

  Future<void> _saveSettings() async {
    await LocalNotificationSettings.saveSettings(
      general: general,
      sound: sound,
      dnd: dnd,
      vibrate: vibrate,
      lockscreen: lockscreen,
      reminders: reminders,
    );
  }

  void _testNotification() {
    if (!general) return;

    NotificationHandler.showNotification(
      title: "FitSense",
      body: "Notificaciones actualizadas",
      sound: sound,
      vibrate: vibrate,      // → se ignora en handler (no vibra)
      lockscreen: lockscreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Notifications Settings",
          style: TextStyle(
            color: Color(0xFFB8B4FF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _switchTile("General Notifications", general, (v) {
            setState(() => general = v);
            _saveSettings();
            _testNotification();
          }),

          _switchTile("Sound", sound, (v) {
            setState(() => sound = v);
            _saveSettings();
            _testNotification();
          }),

          _switchTile("Don't Disturb Mode", dnd, (v) {
            setState(() => dnd = v);
            _saveSettings();
          }),

          // ⚠ Vibrate ahora solo es visual — no usa ningún plugin ni vibra realmente
          _switchTile("Vibrate", vibrate, (v) {
            setState(() => vibrate = v);
            _saveSettings();
          }),

          _switchTile("Lock Screen", lockscreen, (v) {
            setState(() => lockscreen = v);
            _saveSettings();
            _testNotification();
          }),

          _switchTile("Reminders", reminders, (v) {
            setState(() => reminders = v);
            _saveSettings();
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _switchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      activeColor: const Color(0xFFD4FF47),
      onChanged: onChanged,
    );
  }
}
