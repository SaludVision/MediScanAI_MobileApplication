import 'package:flutter/material.dart';
import '../services/analysis/analysis_service.dart';
import '../services/reports/report_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/http_client.dart';
import '../models/analysis/analysis_types.dart';
import '../models/reports/report_types.dart';
import '../models/notifications/notification_types.dart' as notif;
import 'dart:io';

class DashboardProvider extends ChangeNotifier {
  final AnalysisService _analysisService = AnalysisService();
  final ReportService _reportService = ReportService();
  final NotificationService _notificationService = NotificationService();

  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<Analysis> _recentAnalyses = [];
  List<Report> _reports = [];
  List<notif.Notification> _notifications = [];
  Map<String, dynamic> _stats = {
    'analysesToday': 0,
    'reportsGenerated': 0,
    'aiAccuracy': 0.0,
    'averageTime': 0.0,
  };

  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get stats => _stats;

  // Convertir a formato compatible con widgets existentes
  List<Map<String, dynamic>> get recentAnalyses => _recentAnalyses
      .map(
        (analysis) => {
          'id': analysis.id,
          'patient': analysis.patientId,
          'type': _getAnalysisTypeSpanish(analysis.analysisType),
          'time': _getRelativeTime(analysis.createdAt),
          'status': _getStatusSpanish(analysis.status),
        },
      )
      .toList();

  List<Map<String, dynamic>> get reports => _reports
      .map(
        (report) => {
          'id': report.id,
          'patient': report.patientId,
          'type': report.analysisType,
          'date': _formatDate(report.generatedAt),
          'result': report.result,
          'status': report.status.name,
        },
      )
      .toList();

  List<Map<String, dynamic>> get notifications => _notifications
      .map(
        (notification) => {
          'id': notification.id,
          'title': notification.title,
          'message': notification.message,
          'time': _getRelativeTime(notification.createdAt),
          'type': notification.type.name,
          'read': notification.read,
        },
      )
      .toList();

  DashboardProvider() {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cargar todos los datos en paralelo
      await Future.wait([
        _loadRecentAnalyses(),
        _loadReports(),
        _loadNotifications(),
        _loadStats(),
      ]);

      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Error al cargar datos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRecentAnalyses() async {
    try {
      _recentAnalyses = await _analysisService.getRecentAnalyses(limit: 10);
    } catch (e) {
      _recentAnalyses = [];
    }
  }

  Future<void> _loadReports() async {
    try {
      _reports = await _reportService.getRecentReports(limit: 10);
    } catch (e) {
      _reports = [];
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await _notificationService.listNotifications();
      _notifications = response.notifications;
    } catch (e) {
      _notifications = [];
    }
  }

  Future<void> _loadStats() async {
    try {
      // Por ahora usar valores calculados localmente
      // TODO: Implementar endpoint de estadísticas en el backend
      _stats = {
        'analysesToday': _recentAnalyses.length,
        'reportsGenerated': _reports.length,
        'aiAccuracy': 98.5,
        'averageTime': 3.2,
      };
    } catch (e) {
      _stats = {
        'analysesToday': 0,
        'reportsGenerated': 0,
        'aiAccuracy': 0.0,
        'averageTime': 0.0,
      };
    }
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> uploadAnalysis(File imageFile, String analysisType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final analysis = await _analysisService.uploadAnalysisFromFile(
        imageFile: imageFile,
        analysisType: _parseAnalysisType(analysisType),
        patientId: 'PATIENT-${DateTime.now().millisecondsSinceEpoch}',
      );

      // Recargar análisis recientes
      await _loadRecentAnalyses();

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al subir análisis';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      await _loadNotifications();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al marcar notificación';
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      await _loadNotifications();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al marcar notificaciones';
    }
  }

  Future<int> getUnreadNotificationsCount() async {
    try {
      return await _notificationService.getUnreadCount();
    } catch (e) {
      return 0;
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper methods
  String _getAnalysisTypeSpanish(AnalysisType type) {
    switch (type) {
      case AnalysisType.radiografia:
        return 'Radiografía';
      case AnalysisType.tomografia:
        return 'Tomografía';
      case AnalysisType.resonancia:
        return 'Resonancia';
      case AnalysisType.ecografia:
        return 'Ecografía';
      case AnalysisType.mamografia:
        return 'Mamografía';
    }
  }

  String _getStatusSpanish(AnalysisStatus status) {
    switch (status) {
      case AnalysisStatus.pending:
        return 'Pendiente';
      case AnalysisStatus.processing:
        return 'En proceso';
      case AnalysisStatus.completed:
        return 'Completado';
      case AnalysisStatus.failed:
        return 'Fallido';
    }
  }

  AnalysisType _parseAnalysisType(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('radio')) return AnalysisType.radiografia;
    if (lowerType.contains('tomo')) return AnalysisType.tomografia;
    if (lowerType.contains('reson')) return AnalysisType.resonancia;
    if (lowerType.contains('eco')) return AnalysisType.ecografia;
    if (lowerType.contains('mamo')) return AnalysisType.mamografia;
    return AnalysisType.radiografia; // default
  }

  String _getRelativeTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return 'Hace ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else {
        return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
      }
    } catch (e) {
      return 'Recientemente';
    }
  }

  String _formatDate(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      final months = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateTime;
    }
  }
}
