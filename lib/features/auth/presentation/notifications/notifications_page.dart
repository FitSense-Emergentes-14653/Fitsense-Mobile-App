import 'package:flutter/material.dart';
import 'notifications_settings_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Notifications",
            style: TextStyle(
              color: Color(0xFFB8B4FF),
              fontWeight: FontWeight.bold,
            )),
        actions: [
          const Icon(Icons.search, color: Color(0xFFB8B4FF)),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
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
          Expanded(
              child: selectedTab == 0
                  ? _buildReminderList()
                  : _buildSystemList())
        ],
      ),
    );
  }

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

  Widget _buildReminderList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _sectionTitle("Today"),
        _notificationTile(Icons.star, "New Workout Is Available",
            "June 10 – 10:00 AM", Colors.purpleAccent),
        _notificationTile(Icons.water, "Don’t Forget To Drink Water",
            "June 10 – 8:00 AM", Colors.yellow),
        const SizedBox(height: 20),
        _sectionTitle("Yesterday"),
        _notificationTile(Icons.fitness_center,
            "Upper Body Workout Completed!", "June 09 – 6:00 PM", Colors.green),
      ],
    );
  }

  Widget _buildSystemList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _sectionTitle("Today"),
        _notificationTile(Icons.message, "You Have A New Message!",
            "June 10 – 2:00 PM", Colors.yellow),
        _notificationTile(Icons.build, "Scheduled Maintenance.",
            "June 10 – 8:00 AM", Colors.green),
        const SizedBox(height: 20),
        _sectionTitle("Yesterday"),
        _notificationTile(Icons.privacy_tip,
            "We’ve Updated Our Privacy Policy", "June 09 – 1:00 PM", Colors.blue),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFFB8B4FF),
              fontSize: 16,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _notificationTile(
      IconData icon, String title, String time, Color color) {
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
            backgroundColor: color,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(time,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ]),
          )
        ],
      ),
    );
  }
}
