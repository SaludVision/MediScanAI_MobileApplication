import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../models/reports/report_types.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _contentController = TextEditingController();

  String _studyType = 'Radiografía';
  bool _isSubmitting = false;

  final List<String> _studyTypes = [
    'Radiografía',
    'Tomografía',
    'Resonancia Magnética',
    'Ecografía',
    'Mamografía',
    'Electrocardiograma',
    'Análisis de Sangre',
    'Otro',
  ];

  @override
  void dispose() {
    _patientNameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final reportProvider = context.read<ReportProvider>();

    // Get current doctor ID from auth
    // TODO: Get from authProvider.userProfile.id when available
    final doctorId = 1;

    setState(() => _isSubmitting = true);

    final request = CreateReportRequest(
      patientName: _patientNameController.text.trim(),
      studyType: _studyType,
      content: _contentController.text.trim(),
      doctorId: doctorId,
    );

    final success = await reportProvider.createReport(request);

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reportProvider.errorMessage ?? 'Error al crear reporte',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Reporte'), elevation: 0),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creando reporte...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildFormFields(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700]),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Completa los datos del reporte médico. El estado inicial será "Pendiente".',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del paciente
        TextFormField(
          controller: _patientNameController,
          decoration: InputDecoration(
            labelText: 'Nombre del Paciente *',
            hintText: 'Ej: Juan Pérez García',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el nombre del paciente';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),

        // Tipo de estudio
        DropdownButtonFormField<String>(
          initialValue: _studyType,
          decoration: InputDecoration(
            labelText: 'Tipo de Estudio *',
            prefixIcon: const Icon(Icons.medical_services),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: _studyTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _studyType = value);
            }
          },
        ),
        const SizedBox(height: 16),

        // Contenido del reporte
        TextFormField(
          controller: _contentController,
          decoration: InputDecoration(
            labelText: 'Contenido del Reporte *',
            hintText:
                'Describe los hallazgos, diagnóstico y recomendaciones...',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
          maxLines: 8,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el contenido del reporte';
            }
            if (value.trim().length < 20) {
              return 'El contenido debe tener al menos 20 caracteres';
            }
            return null;
          },
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 8),
        Text(
          'Caracteres: ${_contentController.text.length}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton.icon(
      onPressed: _submitReport,
      icon: const Icon(Icons.save),
      label: const Text('Crear Reporte'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
