# MediScan AI - Aplicación Móvil

Una aplicación móvil Flutter para análisis médico de imágenes utilizando inteligencia artificial.

## 📋 Descripción

MediScan AI Mobile es la versión móvil de la aplicación web MediScanAI, diseñada para profesionales médicos que necesitan analizar imágenes médicas con IA en cualquier lugar. La aplicación permite subir imágenes, ver análisis en tiempo real, gestionar reportes y mantener un perfil profesional.

## ✨ Características

### 🔐 Autenticación
- Inicio de sesión seguro
- Registro de nuevos usuarios
- Gestión de perfiles profesionales

### 🏠 Dashboard Principal
- Estadísticas en tiempo real (análisis del día, reportes generados, precisión IA)
- Subida de imágenes para análisis
- Lista de análisis recientes
- Indicador de estado del sistema IA

### 📊 Reportes
- Historial completo de análisis realizados
- Vista detallada de resultados
- Filtros por fecha y tipo de análisis

### 🔔 Notificaciones
- Alertas de análisis completados
- Notificaciones de resultados que requieren atención
- Historial de notificaciones

### 👤 Perfil de Usuario
- Información profesional completa
- Gestión de especialidades médicas
- Datos de contacto e institución

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK instalado (versión 3.10.0 o superior)
- Dart SDK
- Android Studio (para emulador Android) o Xcode (para iOS)
- Dispositivo físico o emulador configurado

### Instalación
1. Clona este repositorio:
```bash
git clone https://github.com/SaludVision/MediScanAI_MobileApplication.git
cd MediScanAI_MobileApplication
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura un dispositivo/emulador:
   - Para Android: Abre Android Studio > AVD Manager
   - Para iOS: Abre Xcode > Simulator

4. Ejecuta la aplicación:
```bash
flutter run
```

## 📱 Uso de la Aplicación

### Primer Uso
1. **Registro**: Crea una cuenta como profesional médico
2. **Inicio de Sesión**: Usa tus credenciales para acceder
3. **Configuración de Perfil**: Completa tu información profesional

### Análisis de Imágenes
1. Ve a la pestaña "Inicio"
2. Toca el botón "Subir Imagen para Análisis"
3. Selecciona una imagen médica de tu galería
4. Espera el procesamiento por IA
5. Revisa los resultados en la sección de reportes

### Navegación
- **Inicio**: Dashboard principal con estadísticas y subida de imágenes
- **Reportes**: Historial de análisis realizados
- **Notificaciones**: Alertas y actualizaciones
- **Soporte**: Centro de ayuda (próximamente)
- **Perfil**: Gestión de información personal

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo móvil
- **Dart**: Lenguaje de programación
- **Provider**: Gestión de estado
- **Material Design 3**: Diseño de interfaz
- **Image Picker**: Selección de imágenes
- **Shared Preferences**: Almacenamiento local

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── providers/                # Gestión de estado
│   ├── auth_provider.dart    # Autenticación
│   └── dashboard_provider.dart # Dashboard y datos
├── screens/                  # Pantallas principales
│   ├── login_screen.dart     # Inicio de sesión
│   ├── register_screen.dart  # Registro
│   └── dashboard_screen.dart # Dashboard principal
├── widgets/                  # Componentes reutilizables
│   ├── custom_button.dart    # Botón personalizado
│   ├── custom_text_field.dart # Campo de texto personalizado
│   └── dashboard_layout.dart # Layout del dashboard
├── models/                   # Modelos de datos
│   └── models.dart           # Definiciones de modelos
├── services/                 # Servicios (API, etc.)
├── utils/                    # Utilidades
└── assets/                   # Recursos estáticos
```

## 🔧 Desarrollo

### Comandos Útiles
```bash
# Verificar instalación de Flutter
flutter doctor

# Ejecutar en modo debug
flutter run --debug

# Ejecutar pruebas
flutter test

# Construir APK
flutter build apk

# Construir para iOS
flutter build ios
```

### Arquitectura
La aplicación sigue el patrón MVVM con Provider para la gestión de estado:
- **Models**: Representan los datos
- **Providers**: Gestionan el estado y la lógica de negocio
- **Screens**: Contienen la UI y manejan la interacción del usuario
- **Widgets**: Componentes reutilizables

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Soporte

Para soporte técnico o preguntas:
- Email: soporte@mediscania.com
- Teléfono: +1 (800) 123-4567

## 🔄 Estado del Proyecto

Esta es la versión inicial de la aplicación móvil. Las siguientes funcionalidades están planificadas:

- [ ] Integración con API backend real
- [ ] Autenticación biométrica
- [ ] Modo offline
- [ ] Compartir reportes
- [ ] Notificaciones push
- [ ] Soporte multiidioma completo
