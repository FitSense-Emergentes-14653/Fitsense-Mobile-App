class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String createdAt;
  final bool isRead;
  final String type; // NEW

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"],
      userId: json["userId"],
      title: json["title"] ?? "",
      body: json["body"] ?? "",
      createdAt: json["createdAt"] ?? "",
      isRead: json["isRead"] ?? false,
      type: json["type"] ?? "SYSTEM", // DEFAULT
    );
  }
}
