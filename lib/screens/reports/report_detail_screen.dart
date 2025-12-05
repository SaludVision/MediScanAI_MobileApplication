import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/report_provider.dart';
import '../../models/reports/report_types.dart';

class ReportDetailScreen extends StatefulWidget {
  final Report report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late Report _currentReport;
  bool _isEditing = false;
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
    _contentController.text = _currentReport.content;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updateContent() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El contenido no puede estar vacío'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = context.read<ReportProvider>();
    final success = await provider.updateReportContent(
      _currentReport.id,
      _contentController.text.trim(),
    );

    if (mounted) {
      if (success && provider.currentReport != null) {
        setState(() {
          _currentReport = provider.currentReport!;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte actualizado'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Error al actualizar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeStatus(ReportStatus newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar estado a ${newStatus.displayName}'),
        content: Text(
          '¿Estás seguro de cambiar el estado del reporte a ${newStatus.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final provider = context.read<ReportProvider>();
    bool success;

    if (newStatus == ReportStatus.approved) {
      success = await provider.approveReport(_currentReport.id);
    } else if (newStatus == ReportStatus.rejected) {
      success = await provider.rejectReport(_currentReport.id);
    } else {
      return;
    }

    if (mounted) {
      if (success && provider.currentReport != null) {
        setState(() {
          _currentReport = provider.currentReport!;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado cambiado a ${newStatus.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Error al cambiar estado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _currentReport.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contenido copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Editar',
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: 'Copiar',
            ),
          if (!_isEditing)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'approve') {
                  _changeStatus(ReportStatus.approved);
                } else if (value == 'reject') {
                  _changeStatus(ReportStatus.rejected);
                }
              },
              itemBuilder: (context) => [
                if (_currentReport.status != ReportStatus.approved)
                  const PopupMenuItem(
                    value: 'approve',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Aprobar'),
                      ],
                    ),
                  ),
                if (_currentReport.status != ReportStatus.rejected)
                  const PopupMenuItem(
                    value: 'reject',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Rechazar'),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(dateFormat),
                const SizedBox(height: 16),
                _buildContentCard(),
                const SizedBox(height: 16),
                _buildMetadataCard(dateFormat),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _isEditing ? _buildEditingBottomBar() : null,
    );
  }

  Widget _buildHeaderCard(DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentReport.patientName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currentReport.studyType,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(_currentReport.status),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Reporte #${_currentReport.id}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contenido del Reporte',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_isEditing)
                  Text(
                    '${_contentController.text.length} caracteres',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Contenido del reporte...',
                ),
                maxLines: 15,
                onChanged: (value) => setState(() {}),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  _currentReport.content,
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard(DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Adicional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person_outline,
              'Doctor ID',
              '#${_currentReport.doctorId}',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.schedule,
              'Creado',
              dateFormat.format(_currentReport.createdAt),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.update,
              'Última actualización',
              dateFormat.format(_currentReport.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color getColor() {
      switch (status) {
        case ReportStatus.pending:
          return Colors.orange;
        case ReportStatus.approved:
          return Colors.green;
        case ReportStatus.rejected:
          return Colors.red;
      }
    }

    IconData getIcon() {
      switch (status) {
        case ReportStatus.pending:
          return Icons.pending;
        case ReportStatus.approved:
          return Icons.check_circle;
        case ReportStatus.rejected:
          return Icons.cancel;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: getColor(), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getIcon(), size: 18, color: getColor()),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: getColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _contentController.text = _currentReport.content;
                });
              },
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: _updateContent,
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
