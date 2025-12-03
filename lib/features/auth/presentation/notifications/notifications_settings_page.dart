import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb; // Disponible si se necesita
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
  bool vibrate = true;
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
      vibrate: vibrate,
      lockscreen: lockscreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final maxWidth = isLargeScreen ? 700.0 : screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: !isLargeScreen,
        title: Text(
          "Configuración de Notificaciones",
          style: TextStyle(
            color: const Color(0xFFB8B4FF),
            fontWeight: FontWeight.bold,
            fontSize: isLargeScreen ? 24 : 20,
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 32 : 16,
              vertical: isLargeScreen ? 24 : 16,
            ),
            children: [
              // Header informativo
              Container(
                padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFCCF24D).withValues(alpha: 0.1),
                      const Color(0xFFC8B8FF).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFCCF24D).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFCCF24D),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Personaliza cómo recibes las notificaciones de FitSense',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLargeScreen ? 14 : 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isLargeScreen ? 32 : 24),

              // Sección: General
              _buildSection(
                'General',
                Icons.notifications_active,
                isLargeScreen,
                [
                  _switchTile(
                    "Notificaciones Generales",
                    "Activar o desactivar todas las notificaciones",
                    Icons.notifications,
                    general,
                    (v) {
                      setState(() => general = v);
                      _saveSettings();
                      _testNotification();
                    },
                    isLargeScreen,
                  ),
                  _switchTile(
                    "Recordatorios",
                    "Recibe recordatorios de entrenamientos y metas",
                    Icons.alarm,
                    reminders,
                    (v) {
                      setState(() => reminders = v);
                      _saveSettings();
                    },
                    isLargeScreen,
                  ),
                ],
              ),

              SizedBox(height: isLargeScreen ? 24 : 16),

              // Sección: Sonido y Vibración
              _buildSection(
                'Sonido y Vibración',
                Icons.volume_up,
                isLargeScreen,
                [
                  _switchTile(
                    "Sonido",
                    "Reproducir sonido con las notificaciones",
                    Icons.music_note,
                    sound,
                    (v) {
                      setState(() => sound = v);
                      _saveSettings();
                      _testNotification();
                    },
                    isLargeScreen,
                  ),
                  _switchTile(
                    "Vibración",
                    "Vibrar cuando llegue una notificación",
                    Icons.vibration,
                    vibrate,
                    (v) {
                      setState(() => vibrate = v);
                      _saveSettings();
                    },
                    isLargeScreen,
                  ),
                ],
              ),

              SizedBox(height: isLargeScreen ? 24 : 16),

              // Sección: Privacidad
              _buildSection(
                'Privacidad',
                Icons.lock,
                isLargeScreen,
                [
                  _switchTile(
                    "Mostrar en Pantalla Bloqueada",
                    "Ver notificaciones cuando el dispositivo está bloqueado",
                    Icons.lock_clock,
                    lockscreen,
                    (v) {
                      setState(() => lockscreen = v);
                      _saveSettings();
                      _testNotification();
                    },
                    isLargeScreen,
                  ),
                  _switchTile(
                    "Modo No Molestar",
                    "Silenciar notificaciones durante horas específicas",
                    Icons.do_not_disturb,
                    dnd,
                    (v) {
                      setState(() => dnd = v);
                      _saveSettings();
                    },
                    isLargeScreen,
                  ),
                ],
              ),

              SizedBox(height: isLargeScreen ? 32 : 24),

              // Botón de prueba
              Center(
                child: ElevatedButton.icon(
                  onPressed: general ? _testNotification : null,
                  icon: const Icon(Icons.send),
                  label: const Text('Probar Notificación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCCF24D),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32 : 24,
                      vertical: isLargeScreen ? 16 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade700,
                    disabledForegroundColor: Colors.grey.shade500,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    bool isLargeScreen,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFCCF24D),
                size: isLargeScreen ? 24 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isLargeScreen ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _switchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isLargeScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 20 : 16,
          vertical: isLargeScreen ? 8 : 4,
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? const Color(0xFFCCF24D).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: value ? const Color(0xFFCCF24D) : Colors.white54,
            size: isLargeScreen ? 24 : 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: isLargeScreen ? 15 : 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isLargeScreen ? 13 : 12,
          ),
        ),
        value: value,
        activeThumbColor: const Color(0xFFCCF24D),
        activeTrackColor: const Color(0xFFCCF24D).withValues(alpha: 0.5),
        inactiveThumbColor: Colors.grey.shade600,
        inactiveTrackColor: Colors.grey.shade800,
        onChanged: onChanged,
      ),
    );
  }
}
