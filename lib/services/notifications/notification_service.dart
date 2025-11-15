import '../http_client.dart';
import '../../config/api_config.dart';
import '../../models/notifications/notification_types.dart';

class NotificationService {
  // List Notifications
  Future<NotificationListResponse> listNotifications() async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiConfig.notificationService.list,
    );

    return NotificationListResponse.fromJson(response);
  }

  // Mark Notification as Read
  Future<void> markAsRead(String id) async {
    await httpClient.put(ApiConfig.notificationService.markRead(id));
  }

  // Mark All Notifications as Read
  Future<void> markAllAsRead() async {
    await httpClient.put(ApiConfig.notificationService.markAllRead);
  }

  // Get Unread Notifications
  Future<List<Notification>> getUnreadNotifications() async {
    final response = await listNotifications();
    return response.notifications.where((n) => !n.read).toList();
  }

  // Get Unread Count
  Future<int> getUnreadCount() async {
    final response = await listNotifications();
    return response.unreadCount;
  }

  // Get Notifications by Type
  Future<List<Notification>> getNotificationsByType(
    NotificationType type,
  ) async {
    final response = await listNotifications();
    return response.notifications.where((n) => n.type == type).toList();
  }
}
