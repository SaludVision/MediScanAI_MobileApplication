import 'package:flutter/material.dart';
import '../services/reports/report_service.dart';
import '../models/reports/report_types.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  List<Report> _reports = [];
  Report? _currentReport;
  bool _isLoading = false;
  String? _errorMessage;

  List<Report> get reports => _reports;
  Report? get currentReport => _currentReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get reports by doctor
  Future<void> loadReportsByDoctor(int doctorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reports = await _reportService.getReportsByDoctor(doctorId);
      print('✅ Loaded ${_reports.length} reports');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('❌ Error loading reports: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get recent reports
  Future<void> loadRecentReports({int limit = 10}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reports = await _reportService.getRecentReports(limit: limit);
      print('✅ Loaded ${_reports.length} recent reports');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('❌ Error loading recent reports: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get report by ID
  Future<void> loadReportById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentReport = await _reportService.getReportById(id);
      print('✅ Loaded report: ${_currentReport!.id}');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('❌ Error loading report: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create report
  Future<bool> createReport(CreateReportRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await _reportService.createReport(request);
      _currentReport = report;

      // Add to list if not already there
      if (!_reports.any((r) => r.id == report.id)) {
        _reports.insert(0, report);
      }

      print('✅ Report created: ${report.id}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('❌ Error creating report: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update report
  Future<bool> updateReport(int id, UpdateReportRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await _reportService.updateReport(id, request);

      // Update in list
      final index = _reports.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reports[index] = report;
      }

      // Update current if it's the same
      if (_currentReport?.id == id) {
        _currentReport = report;
      }

      print('✅ Report updated: ${report.id}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('❌ Error updating report: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Approve report
  Future<bool> approveReport(int id) async {
    return updateReport(id, UpdateReportRequest(status: 'APPROVED'));
  }

  // Reject report
  Future<bool> rejectReport(int id) async {
    return updateReport(id, UpdateReportRequest(status: 'REJECTED'));
  }

  // Update report content
  Future<bool> updateReportContent(int id, String content) async {
    return updateReport(id, UpdateReportRequest(content: content));
  }

  // Filter reports by status
  List<Report> getReportsByStatus(ReportStatus status) {
    return _reports.where((r) => r.status == status).toList();
  }

  // Get report count by status
  Map<ReportStatus, int> getReportCountByStatus() {
    final counts = <ReportStatus, int>{
      ReportStatus.pending: 0,
      ReportStatus.approved: 0,
      ReportStatus.rejected: 0,
    };

    for (var report in _reports) {
      counts[report.status] = (counts[report.status] ?? 0) + 1;
    }

    return counts;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCurrentReport() {
    _currentReport = null;
    notifyListeners();
  }
}
