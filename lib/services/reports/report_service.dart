import '../http_client.dart';
import '../../config/api_config.dart';
import '../../models/reports/report_types.dart';
import '../../models/analysis/analysis_types.dart';

class ReportService {
  // Get Report by ID
  Future<Report> getReportById(String id) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiConfig.reportService.getById(id),
    );

    return Report.fromJson(response);
  }

  // List Reports
  Future<ReportListResponse> listReports([PaginationParams? params]) async {
    final queryParams = params?.toQueryParameters() ?? {};

    final response = await httpClient.get<Map<String, dynamic>>(
      ApiConfig.reportService.list,
      queryParameters: queryParams,
    );

    return ReportListResponse.fromJson(response);
  }

  // Download Report
  Future<String> downloadReport(String id) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiConfig.reportService.download(id),
    );

    return response['downloadUrl'];
  }

  // Get Recent Reports
  Future<List<Report>> getRecentReports({int limit = 10}) async {
    final params = PaginationParams(
      page: 1,
      pageSize: limit,
      sortBy: 'generatedAt',
      sortOrder: 'desc',
    );

    final response = await listReports(params);
    return response.reports;
  }

  // Get Reports by Status
  Future<List<Report>> getReportsByStatus(
    ReportStatus status, {
    int limit = 10,
  }) async {
    // TODO: Implementar filtrado por estado en el backend
    final response = await listReports();
    return response.reports
        .where((r) => r.status == status)
        .take(limit)
        .toList();
  }
}
