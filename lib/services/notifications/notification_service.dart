import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../models/notifications/notification_types.dart';

class NotificationService {
  // Create Notification
  Future<Notification> createNotification(String message, int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final request = CreateNotificationRequest(
      message: message,
      doctorId: doctorId,
    );

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationService.create}'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return Notification.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create notification: ${response.body}');
    }
  }

  // Get Notifications by Doctor ID
  Future<List<Notification>> getNotificationsByDoctor(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.notificationService.getByDoctor(doctorId)}',
      ),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Notification.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications: ${response.body}');
    }
  }

  // Get Unread Notifications
  Future<List<Notification>> getUnreadNotifications(int doctorId) async {
    final notifications = await getNotificationsByDoctor(doctorId);
    return notifications.where((n) => !n.isRead).toList();
  }

  // Get Unread Count
  Future<int> getUnreadCount(int doctorId) async {
    final unreadNotifications = await getUnreadNotifications(doctorId);
    return unreadNotifications.length;
  }

  // Get Recent Notifications (last N notifications)
  Future<List<Notification>> getRecentNotifications(
    int doctorId, {
    int limit = 10,
  }) async {
    final notifications = await getNotificationsByDoctor(doctorId);
    return notifications.take(limit).toList();
  }
}
