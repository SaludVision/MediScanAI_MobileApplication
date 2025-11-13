import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _isLoading = false;

  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;

  final List<Map<String, dynamic>> _recentAnalyses = [
    {
      'id': 1,
      'patient': 'Paciente #1245',
      'type': 'Radiografía',
      'time': 'Hace 5 min',
      'status': 'Completado',
    },
    {
      'id': 2,
      'patient': 'Paciente #1246',
      'type': 'Tomografía',
      'time': 'Hace 15 min',
      'status': 'En proceso',
    },
    {
      'id': 3,
      'patient': 'Paciente #1247',
      'type': 'Resonancia',
      'time': 'Hace 30 min',
      'status': 'Completado',
    },
  ];

  final List<Map<String, dynamic>> _reports = [
    {
      'id': 1,
      'patient': 'Paciente #1245',
      'type': 'Radiografía de Tórax',
      'date': '12 Nov 2024',
      'result': 'Normal',
      'status': 'success',
    },
    {
      'id': 2,
      'patient': 'Paciente #1243',
      'type': 'Tomografía Cerebral',
      'date': '11 Nov 2024',
      'result': 'Requiere revisión',
      'status': 'warning',
    },
  ];

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Análisis completado',
      'message':
          'El análisis de Radiografía de Tórax para Paciente #1245 ha finalizado',
      'time': 'Hace 5 min',
      'type': 'success',
      'read': false,
    },
    {
      'id': 2,
      'title': 'Requiere atención',
      'message': 'El análisis de Tomografía Cerebral necesita revisión médica',
      'time': 'Hace 1 hora',
      'type': 'warning',
      'read': false,
    },
  ];

  List<Map<String, dynamic>> get recentAnalyses => _recentAnalyses;
  List<Map<String, dynamic>> get reports => _reports;
  List<Map<String, dynamic>> get notifications => _notifications;

  Map<String, dynamic> get stats => {
    'analysesToday': 12,
    'reportsGenerated': 89,
    'aiAccuracy': 98.5,
    'averageTime': 3.2,
  };

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> uploadAnalysis(String filePath, String analysisType) async {
    _isLoading = true;
    notifyListeners();

    // Simular procesamiento
    await Future.delayed(const Duration(seconds: 3));

    // Agregar nuevo análisis a la lista
    _recentAnalyses.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'patient': 'Nuevo Paciente',
      'type': analysisType,
      'time': 'Ahora',
      'status': 'Completado',
    });

    _isLoading = false;
    notifyListeners();
  }

  void markNotificationAsRead(int id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['read'] = true;
      notifyListeners();
    }
  }
}
