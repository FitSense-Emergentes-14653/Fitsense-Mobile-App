import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/config/app_config.dart';

class NotificationApiService {
  static Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    required String type,
  }) async {
    final url = Uri.parse("${AppConfig.apiBaseUrl}/notifications");

    try {
      await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "title": title,
          "body": body,
          "type": type,
        }),
      );
    } catch (e) {
      print("❌ Error al enviar notificación '$type': $e");
    }
  }
}
