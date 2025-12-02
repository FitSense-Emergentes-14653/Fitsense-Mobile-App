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
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Color(0xFFB8B4FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const Icon(Icons.search, color: Color(0xFFB8B4FF)),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsPage()),
              );
            },
            icon: const Icon(
              Icons.person,
              color: Color(0xFFB8B4FF),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          const SizedBox(height: 16),
          Expanded(child: _buildNotificationList())
        ],
      ),
    );
  }

  // ----------------------------- TABS ---------------------------------

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabButton("Reminders", selectedTab == 0, () {
          setState(() => selectedTab = 0);
        }),
        const SizedBox(width: 12),
        _tabButton("System", selectedTab == 1, () {
          setState(() => selectedTab = 1);
        }),
      ],
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD4FF47) : Colors.white10,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ----------------------------- LISTA ---------------------------------

  Widget _buildNotificationList() {
    return FutureBuilder(
      future: notificationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Error al cargar notificaciones",
              style: TextStyle(color: Colors.white),
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
          return const Center(
            child: Text(
              "No hay notificaciones aquí",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: listToShow.length,
          itemBuilder: (context, index) {
            return _notificationTile(listToShow[index]);
          },
        );
      },
    );
  }

  // --------------------------- TILE -----------------------------------

  Widget _notificationTile(NotificationModel notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: notif.isRead ? Colors.grey : Colors.greenAccent,
            child: const Icon(Icons.notifications, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notif.body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDate(notif.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
