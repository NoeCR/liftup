# 🏋️‍♂️ LiftUp

**LiftUp** es una aplicación móvil desarrollada en Flutter para gestionar rutinas de ejercicios con una arquitectura limpia y moderna.

## ✨ Características

- 🏗️ **Arquitectura limpia** orientada a features
- 🔄 **Gestión de estado** con Riverpod
- 💾 **Base de datos local** con Hive (offline-first)
- 🧭 **Navegación** con go_router
- 🎨 **Material You** con soporte para tema claro/oscuro
- 🌍 **Internacionalización** (Español/Inglés)
- 📊 **Sistema de exportación** (CSV, PDF, JSON)
- ⏱️ **Sesiones de entrenamiento** con timer
- 📈 **Estadísticas y progreso** histórico
- 🎯 **Gestión de ejercicios** con categorías y dificultad

## 🚀 Inicio Rápido

### Prerrequisitos

- Flutter 3.7.2 o superior
- Dart 3.0 o superior

### Instalación

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/TU_USUARIO/liftup.git
   cd liftup
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Genera el código necesario**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 📱 Capturas de Pantalla

*Próximamente...*

## 🏗️ Arquitectura

El proyecto sigue una **arquitectura limpia** orientada a features:

```
lib/
├── features/           # Módulos por funcionalidad
│   ├── home/          # Pantalla principal y rutinas
│   ├── exercise/      # Gestión de ejercicios
│   ├── sessions/      # Sesiones de entrenamiento
│   ├── statistics/    # Estadísticas y progreso
│   └── settings/      # Configuración
├── common/            # Componentes compartidos
│   ├── widgets/       # Widgets reutilizables
│   ├── themes/        # Temas y estilos
│   └── localization/  # Internacionalización
└── core/              # Funcionalidades centrales
    ├── database/      # Configuración de Hive
    ├── export/        # Sistema de exportación
    └── navigation/    # Configuración de rutas
```

## 🛠️ Tecnologías

- **Flutter** - Framework de desarrollo móvil
- **Riverpod** - Gestión de estado reactiva
- **Hive** - Base de datos local NoSQL
- **go_router** - Navegación declarativa
- **Material You** - Sistema de diseño moderno
- **fl_chart** - Gráficos para estadísticas
- **pdf** - Generación de PDFs
- **share_plus** - Compartir archivos

## 📖 Documentación

- [Guía de Desarrollo](DEVELOPMENT_GUIDE.md) - Guía completa para desarrolladores
- [Resumen del Proyecto](PROJECT_SUMMARY.md) - Resumen detallado de funcionalidades

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👨‍💻 Autor

**Tu Nombre**
- GitHub: [@TU_USUARIO](https://github.com/TU_USUARIO)

## 🙏 Agradecimientos

- Flutter team por el increíble framework
- Riverpod por la gestión de estado
- Hive por la base de datos local
- Material Design por el sistema de diseño

---

⭐ **¡Dale una estrella si te gusta el proyecto!** ⭐
