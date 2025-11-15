import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _dniController = TextEditingController();
  final _professionalIdController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specialtyController.dispose();
    _dniController.dispose();
    _professionalIdController.dispose();
    _hospitalController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'specialty': _specialtyController.text,
        'dni': _dniController.text,
        'professionalId': _professionalIdController.text,
        'hospital': _hospitalController.text,
        'phone': _phoneController.text,
      };

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(userData);

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _errorMessage =
              authProvider.errorMessage ?? 'Error al registrar usuario';
        });
      }
    } catch (e) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _errorMessage =
            authProvider.errorMessage ??
            'Error de conexión. Intenta nuevamente.\n\nDetalles: ${e.toString()}';
      });
      // Print para debug
      print('Error de registro: $e');
      print('Error del provider: ${authProvider.errorMessage}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Regístrate como profesional médico',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          CustomTextField(
                            controller: _nameController,
                            label: 'Nombre completo',
                            hint: 'Dr. Juan Pérez',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _emailController,
                            label: 'Correo electrónico',
                            hint: 'tu@email.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            hint: 'Mínimo 6 caracteres',
                            obscureText: true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirmar contraseña',
                            hint: 'Repite tu contraseña',
                            obscureText: true,
                            validator: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _specialtyController,
                            label: 'Especialidad médica',
                            hint: 'Ej: Radiología, Cardiología',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La especialidad es requerida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _dniController,
                            label: 'DNI',
                            hint: '12345678',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _professionalIdController,
                            label: 'ID Profesional',
                            hint: 'MED001',
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _hospitalController,
                            label: 'Hospital / Centro Médico',
                            hint: 'Hospital Central',
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _phoneController,
                            label: 'Teléfono',
                            hint: '+1234567890',
                            keyboardType: TextInputType.phone,
                          ),

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          CustomButton(
                            text: 'Crear Cuenta',
                            onPressed: _isLoading ? null : _register,
                            isLoading: _isLoading,
                          ),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: RichText(
                              text: TextSpan(
                                text: '¿Ya tienes cuenta? ',
                                style: TextStyle(color: Colors.grey[600]),
                                children: [
                                  TextSpan(
                                    text: 'Inicia sesión',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
