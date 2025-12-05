import 'package:flutter/material.dart';
import '../services/analysis/analysis_service.dart';
import '../services/reports/report_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/http_client.dart';
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
          'id': report.id.toString(),
          'patient': report.patientName,
          'type': report.studyType,
          'date': _formatDate(report.createdAt.toIso8601String()),
          'result': report.content.length > 50
              ? '${report.content.substring(0, 50)}...'
              : report.content,
          'status': report.status.displayName,
        },
      )
      .toList();

  List<Map<String, dynamic>> get notifications => _notifications
      .map(
        (notification) => {
          'id': notification.id,
          'message': notification.message,
          'time': _getRelativeTime(notification.createdAt),
          'isRead': notification.isRead,
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
      // Cargar TODO el historial para obtener el conteo real
      final history = await _analysisService.getHistory();

      // Convertir AnalysisHistory a Analysis (formato compatible)
      // Tomar solo los últimos 2 análisis
      _recentAnalyses = history.take(2).map((historyItem) {
        return Analysis(
          id: historyItem.id,
          patientId: historyItem.patientName,
          analysisType: _parseAnalysisType(historyItem.studyType),
          createdAt: historyItem.timestamp.toIso8601String(),
          status: AnalysisStatus.completed,
          result: historyItem.diagnosis,
          imageUrl: historyItem.imagePath,
        );
      }).toList();
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
      // TODO: Get actual doctor ID from AuthProvider
      final doctorId = 1;
      _notifications = await _notificationService.getNotificationsByDoctor(
        doctorId,
      );
    } catch (e) {
      _notifications = [];
    }
  }

  Future<void> _loadStats() async {
    try {
      // Obtener el conteo real de análisis del historial
      final history = await _analysisService.getHistory();
      final totalAnalyses = history.length;

      _stats = {
        'analysesToday': totalAnalyses, // Total de análisis realizados
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
      await _analysisService.uploadAnalysisFromFile(
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

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      // TODO: Implement markAsRead endpoint in backend
      // For now, just reload notifications
      await _loadNotifications();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al marcar notificación';
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      // TODO: Implement markAllAsRead endpoint in backend
      // For now, just reload notifications
      await _loadNotifications();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al marcar notificaciones';
    }
  }

  Future<int> getUnreadNotificationsCount() async {
    try {
      // TODO: Get actual doctor ID from AuthProvider
      final doctorId = 1;
      return await _notificationService.getUnreadCount(doctorId);
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

  String _getRelativeTime(dynamic dateTime) {
    try {
      DateTime date;
      if (dateTime is DateTime) {
        date = dateTime;
      } else if (dateTime is String) {
        date = DateTime.parse(dateTime);
      } else {
        return 'Recientemente';
      }

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
