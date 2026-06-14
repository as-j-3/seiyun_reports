class AppNotification {
  final int? id;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final String userId;

  AppNotification({
    this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.userId = '',
  });

  /// تحويل كائن الإشعار إلى Map للتخزين
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'time': time.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'user_id': userId,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      time: DateTime.parse(map['time']),
      isRead: map['is_read'] == 1,
      userId: map['user_id'] ?? '',
    );
  }
}
