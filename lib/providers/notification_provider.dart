import 'package:flutter/foundation.dart';
import '../models/notifications/notification_types.dart';
import '../services/notifications/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<Notification> _notifications = [];
  Notification? _currentNotification;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Notification> get notifications => _notifications;
  Notification? get currentNotification => _currentNotification;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get unread notifications count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Get unread notifications
  List<Notification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  // Load notifications by doctor ID
  Future<void> loadNotificationsByDoctor(int doctorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotificationsByDoctor(
        doctorId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Load recent notifications
  Future<void> loadRecentNotifications(int doctorId, {int limit = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getRecentNotifications(
        doctorId,
        limit: limit,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Create notification
  Future<void> createNotification(String message, int doctorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final notification = await _notificationService.createNotification(
        message,
        doctorId,
      );

      // Add to the beginning of the list
      _notifications.insert(0, notification);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get unread count
  Future<int> getUnreadCount(int doctorId) async {
    try {
      return await _notificationService.getUnreadCount(doctorId);
    } catch (e) {
      return 0;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear notifications
  void clearNotifications() {
    _notifications = [];
    _currentNotification = null;
    notifyListeners();
  }
}
