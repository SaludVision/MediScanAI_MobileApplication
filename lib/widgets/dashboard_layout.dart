import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../screens/login_screen.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, DashboardProvider>(
      builder: (context, authProvider, dashboardProvider, _) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('MediScan AI'),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  authProvider.logout();
                },
              ),
            ],
          ),
          body: _getCurrentTab(dashboardProvider.selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: dashboardProvider.selectedIndex,
            onTap: dashboardProvider.setSelectedIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(
                icon: Icon(Icons.description),
                label: 'Reportes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Notificaciones',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.support),
                label: 'Soporte',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(
              0xFF207193,
            ), // Azul del sidebar activo
            unselectedItemColor: const Color(0xFF6B7280), // Gris
            backgroundColor: Colors.white,
            elevation: 8,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: -0.72,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              letterSpacing: -0.72,
            ),
          ),
        );
      },
    );
  }

  Widget _getCurrentTab(int index) {
    switch (index) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildReportsTab();
      case 2:
        return _buildNotificationsTab();
      case 3:
        return _buildSupportTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel de Análisis Médico',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Análisis de imágenes médicas con inteligencia artificial',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Análisis Hoy',
                    stats['analysesToday'].toString(),
                    Icons.analytics,
                    const Color(0xFF207193), // Azul primario del frontend
                  ),
                  _buildStatCard(
                    'Reportes',
                    stats['reportsGenerated'].toString(),
                    Icons.description,
                    const Color(0xFF8B5CF6), // Púrpura del frontend
                  ),
                  _buildStatCard(
                    'Precisión IA',
                    '${stats['aiAccuracy']}%',
                    Icons.precision_manufacturing,
                    const Color(0xFF10B981), // Verde del frontend
                  ),
                  _buildStatCard(
                    'Tiempo Promedio',
                    '${stats['averageTime']} min',
                    Icons.timer,
                    const Color(0xFFF59E0B), // Naranja del frontend
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Upload Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement image upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función de subida próximamente'),
                        backgroundColor: Color(0xFF207193),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_file, size: 24),
                  label: const Text(
                    'Subir Imagen para Análisis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.72,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF207193,
                    ), // Azul primario del frontend
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Bordes consistentes con el frontend
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Analyses
              const Text(
                'Análisis Recientes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ...provider.recentAnalyses.map(
                (analysis) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: Text(analysis['patient']),
                    subtitle: Text('${analysis['type']} • ${analysis['time']}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: analysis['status'] == 'Completado'
                            ? const Color(
                                0xFFD1FAE5,
                              ) // Verde claro del frontend web
                            : const Color(
                                0xFFFEF3C7,
                              ), // Amarillo claro del frontend web
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Bordes consistentes
                      ),
                      child: Text(
                        analysis['status'],
                        style: TextStyle(
                          color: analysis['status'] == 'Completado'
                              ? const Color(
                                  0xFF10B981,
                                ) // Verde del frontend web
                              : const Color(
                                  0xFFF59E0B,
                                ), // Amarillo del frontend web
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportsTab() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.reports.length,
          itemBuilder: (context, index) {
            final report = provider.reports[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.description),
                title: Text(report['patient']),
                subtitle: Text('${report['type']} • ${report['date']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: report['status'] == 'success'
                        ? const Color(
                            0xFFD1FAE5,
                          ) // Verde claro del frontend web
                        : const Color(
                            0xFFFEF3C7,
                          ), // Amarillo claro del frontend web
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Bordes consistentes
                  ),
                  child: Text(
                    report['result'],
                    style: TextStyle(
                      color: report['status'] == 'success'
                          ? const Color(0xFF10B981) // Verde del frontend web
                          : const Color(
                              0xFFF59E0B,
                            ), // Amarillo del frontend web
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () {
                  // TODO: Show report details
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationsTab() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.notifications.length,
          itemBuilder: (context, index) {
            final notification = provider.notifications[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  notification['type'] == 'success'
                      ? Icons.check_circle
                      : Icons.warning,
                  color: notification['type'] == 'success'
                      ? const Color(0xFF10B981) // Verde del frontend web
                      : const Color(0xFFF59E0B), // Amarillo del frontend web
                ),
                title: Text(notification['title']),
                subtitle: Text(
                  '${notification['message']} • ${notification['time']}',
                ),
                trailing: notification['read']
                    ? null
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFF207193,
                          ), // Azul primario del frontend web
                          shape: BoxShape.circle,
                        ),
                      ),
                onTap: () {
                  provider.markNotificationAsRead(notification['id']);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSupportTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Centro de Soporte',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Estamos trabajando en esta sección',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final profile = authProvider.userProfile;
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mi Perfil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    profile['name']
                        .toString()
                        .split(' ')
                        .map((e) => e[0])
                        .join(''),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildProfileField('Nombre', profile['name']),
              _buildProfileField('Email', profile['email']),
              _buildProfileField('Especialidad', profile['specialty']),
              _buildProfileField('DNI', profile['dni']),
              _buildProfileField('ID Profesional', profile['professionalId']),
              _buildProfileField('Hospital', profile['hospital']),
              _buildProfileField('Teléfono', profile['phone']),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement profile editing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función de edición próximamente'),
                      ),
                    );
                  },
                  child: const Text('Editar Perfil'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value?.toString() ?? 'No especificado',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
