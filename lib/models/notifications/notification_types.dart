// Notification Types - Matching Spring Boot Backend

class Notification {
  final int id;
  final String message;
  final int doctorId;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.message,
    required this.doctorId,
    required this.isRead,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json['id'] as int,
    message: json['message'] as String,
    doctorId: json['doctorId'] as int? ?? 0,
    isRead: json['read'] as bool? ?? json['isRead'] as bool? ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'doctorId': doctorId,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };

  Notification copyWith({
    int? id,
    String? message,
    int? doctorId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      message: message ?? this.message,
      doctorId: doctorId ?? this.doctorId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// DTOs - Request/Response models

class CreateNotificationRequest {
  final String message;
  final int doctorId;

  CreateNotificationRequest({required this.message, required this.doctorId});

  Map<String, dynamic> toJson() => {'message': message, 'doctorId': doctorId};
}
