import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/config/app_config.dart';

import 'notifications_model.dart';
import 'notifications_settings_page.dart';

class NotificationsPage extends StatefulWidget {
  final int userId;
  final String authToken;

  const NotificationsPage({
    super.key,
    required this.userId,
    required this.authToken,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int selectedTab = 0;
  late Future<List<NotificationModel>> notificationFuture;

  @override
  void initState() {
    super.initState();
    notificationFuture = fetchNotifications();
  }

  // ------------------------- FETCH API --------------------------
  Future<List<NotificationModel>> fetchNotifications() async {
    final url = Uri.parse(
      "${AppConfig.apiBaseUrl}/notifications/user/${widget.userId}",
    );

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer ${widget.authToken}",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar notificaciones");
    }
  }

  // ------------------------- DATE FORMATTER --------------------------
  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();

    String month = _monthShort(date.month);
    String day = date.day.toString();
    String hour =
    date.hour > 12 ? (date.hour - 12).toString() : date.hour.toString();
    String minute = date.minute.toString().padLeft(2, '0');
    String period = date.hour >= 12 ? "PM" : "AM";

    return "$month $day – $hour:$minute $period";
  }

  String _monthShort(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m - 1];
  }

  // ----------------------------- UI ---------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    final maxWidth = isWeb ? 900.0 : screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: !isWeb,
        title: Text(
          "Notificaciones",
          style: TextStyle(
            color: const Color(0xFFB8B4FF),
            fontWeight: FontWeight.bold,
            fontSize: isWeb ? 24 : 20,
          ),
        ),
        actions: [
          if (isWeb) ...[
            // Mostrar más información en web
            TextButton.icon(
              onPressed: () {
                setState(() {
                  notificationFuture = fetchNotifications();
                });
              },
              icon: const Icon(Icons.refresh, color: Color(0xFFB8B4FF)),
              label: const Text(
                'Actualizar',
                style: TextStyle(color: Color(0xFFB8B4FF)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: () {
              // TODO: Implementar búsqueda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Búsqueda próximamente'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.search, color: Color(0xFFB8B4FF)),
            tooltip: 'Buscar',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: Color(0xFFB8B4FF),
            ),
            tooltip: 'Configuración',
          ),
          SizedBox(width: isWeb ? 16 : 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              SizedBox(height: isWeb ? 24 : 16),
              _buildTabs(isWeb),
              SizedBox(height: isWeb ? 24 : 16),
              Expanded(child: _buildNotificationList(isWeb)),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------- TABS ---------------------------------

  Widget _buildTabs(bool isWeb) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 32 : 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              "Recordatorios",
              Icons.alarm,
              selectedTab == 0,
              () => setState(() => selectedTab = 0),
              isWeb,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _tabButton(
              "Sistema",
              Icons.notifications_active,
              selectedTab == 1,
              () => setState(() => selectedTab = 1),
              isWeb,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(
    String text,
    IconData icon,
    bool active,
    VoidCallback onTap,
    bool isWeb,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 32 : 16,
          vertical: isWeb ? 14 : 12,
        ),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFFD4FF47), Color(0xFFCCF24D)],
                )
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4FF47).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? Colors.black : Colors.white70,
              size: isWeb ? 20 : 18,
            ),
            if (isWeb) ...[
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: active ? Colors.black : Colors.white70,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ----------------------------- LISTA ---------------------------------

  Widget _buildNotificationList(bool isWeb) {
    return FutureBuilder(
      future: notificationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFCCF24D),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: isWeb ? 64 : 48,
                  color: Colors.red.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Error al cargar notificaciones",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      notificationFuture = fetchNotifications();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Color(0xFFCCF24D)),
                  label: const Text(
                    'Reintentar',
                    style: TextStyle(color: Color(0xFFCCF24D)),
                  ),
                ),
              ],
            ),
          );
        }

        final notifications = snapshot.data!;

        // ---------------------- SEPARAR POR TIPO ----------------------
        final reminders = notifications
            .where((n) => n.type.toUpperCase() == "REMINDER")
            .toList();

        final system = notifications
            .where((n) => n.type.toUpperCase() == "SYSTEM")
            .toList();

        // ---------------------- ORDENAR POR FECHA ----------------------
        reminders.sort((a, b) =>
            DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

        system.sort((a, b) =>
            DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

        // Seleccionar la lista correcta según el tab
        final listToShow = selectedTab == 0 ? reminders : system;

        if (listToShow.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selectedTab == 0 ? Icons.alarm_off : Icons.notifications_off,
                    size: isWeb ? 64 : 48,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  selectedTab == 0
                      ? "No tienes recordatorios"
                      : "No hay notificaciones del sistema",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedTab == 0
                      ? "Tus recordatorios aparecerán aquí"
                      : "Las notificaciones del sistema aparecerán aquí",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Layout responsive
        if (isWeb && listToShow.length > 0) {
          // En web, mostrar en grid si hay muchas notificaciones
          return GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 32 : 16,
              vertical: 8,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3.5,
            ),
            itemCount: listToShow.length,
            itemBuilder: (context, index) {
              return _notificationTile(listToShow[index], isWeb);
            },
          );
        }

        // En mobile, mostrar en lista
        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 32 : 16,
            vertical: 8,
          ),
          itemCount: listToShow.length,
          itemBuilder: (context, index) {
            return _notificationTile(listToShow[index], isWeb);
          },
        );
      },
    );
  }

  // --------------------------- TILE -----------------------------------

  Widget _notificationTile(NotificationModel notif, bool isWeb) {
    final bool isRead = notif.isRead;
    final bool isReminder = notif.type.toUpperCase() == "REMINDER";

    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 0 : 12),
      padding: EdgeInsets.all(isWeb ? 16 : 14),
      decoration: BoxDecoration(
        gradient: isRead
            ? null
            : LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.98),
                ],
              ),
        color: isRead ? Colors.white.withValues(alpha: 0.85) : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? Colors.white.withValues(alpha: 0.3)
              : const Color(0xFFCCF24D).withValues(alpha: 0.5),
          width: isRead ? 1 : 2,
        ),
        boxShadow: isRead
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFFCCF24D).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: isRead
                  ? LinearGradient(
                      colors: [
                        Colors.grey.shade400,
                        Colors.grey.shade500,
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        const Color(0xFFCCF24D),
                        const Color(0xFFC8B8FF),
                      ],
                    ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isReminder ? Icons.alarm : Icons.notifications_active,
              color: Colors.black,
              size: isWeb ? 24 : 20,
            ),
          ),
          SizedBox(width: isWeb ? 16 : 12),

          // Contenido
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isWeb ? 15 : 14,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isRead) ...[
                      const SizedBox(width: 4),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCF24D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NUEVO',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    notif.body,
                    style: TextStyle(
                      fontSize: isWeb ? 13 : 12,
                      color: Colors.black87,
                    ),
                    maxLines: isWeb ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: isWeb ? 14 : 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        formatDate(notif.createdAt),
                        style: TextStyle(
                          fontSize: isWeb ? 12 : 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botón de acción (opcional)
          if (isWeb) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                // TODO: Marcar como leído o eliminar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Acción próximamente'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: Icon(
                isRead ? Icons.delete_outline : Icons.check,
                color: Colors.grey.shade700,
                size: 20,
              ),
              tooltip: isRead ? 'Eliminar' : 'Marcar como leído',
            ),
          ],
        ],
      ),
    );
  }
}
