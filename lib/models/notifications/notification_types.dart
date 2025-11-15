// Notification Types

enum NotificationType {
  success,
  warning,
  info,
  error;

  String toJson() => name;

  static NotificationType fromJson(String json) {
    return NotificationType.values.firstWhere((e) => e.name == json);
  }
}

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool read;
  final String createdAt;
  final Map<String, dynamic>? metadata;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
    this.metadata,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    message: json['message'],
    type: NotificationType.fromJson(json['type']),
    read: json['read'],
    createdAt: json['createdAt'],
    metadata: json['metadata'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'type': type.toJson(),
    'read': read,
    'createdAt': createdAt,
    if (metadata != null) 'metadata': metadata,
  };

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    bool? read,
    String? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class NotificationListResponse {
  final List<Notification> notifications;
  final int total;
  final int unreadCount;

  NotificationListResponse({
    required this.notifications,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      NotificationListResponse(
        notifications: (json['notifications'] as List)
            .map((e) => Notification.fromJson(e))
            .toList(),
        total: json['total'],
        unreadCount: json['unreadCount'],
      );
}
