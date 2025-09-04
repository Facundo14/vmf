

# vmf (Version Manager Flavors)

> Herramienta CLI profesional para automatizar la gestión de flavors y versionado en proyectos Flutter.

## ✨ Características

- **Inicialización interactiva** de flavors con configuración automática (`vmf init`)
- **Modificación inteligente** de `build.gradle(.kts)` con detección de sintaxis Kotlin DSL/Groovy
- **Generación automática de keystores** con keytool para cada flavor (Android)
- **Configuración automática** de signingConfigs, buildTypes, flavorDimensions y productFlavors (Android)
- **Eliminación de duplicados** y limpieza automática de bloques previos
- **Build optimizado** para flavors con flags de producción (`vmf build <flavor>`)
- **Versionado semántico** automatizado (`vmf version [patch|minor|major]`)
- **Compatibilidad multiplataforma** (Windows, macOS, Linux)

> ⚠️ **Nota importante**: Actualmente vmf solo configura automáticamente **Android**. Para iOS, web y desktop, solo maneja el versionado y build básico de Flutter.

## 📦 Instalación

### Instalación local en proyecto:
```yaml
# pubspec.yaml
dev_dependencies:
  vmf:
    path: ./vmf
```

### Instalación global:
```bash
dart pub global activate --source path ./vmf
```

## 🚀 Uso

### Inicialización de flavors
```bash
# Ejecutar en la raíz de tu proyecto Flutter
vmf init
```

**¿Qué hace `vmf init`?**
1. Solicita cantidad de flavors, nombres y datos de configuración
2. Pide applicationId, nombre de app y credenciales de keystore para cada flavor
3. **Genera automáticamente** los keystores con `keytool` si no existen
4. **Detecta y limpia** bloques previos en build.gradle(.kts) para evitar duplicados
5. **Modifica inteligentemente** build.gradle(.kts) agregando:
   - `signingConfigs` con las credenciales de cada flavor
   - `buildTypes` (debug/release) con signingConfig apropiado
   - `flavorDimensions` configurado correctamente
   - `productFlavors` con applicationId y resValue para app_name
6. **Actualiza AndroidManifest.xml** para usar `@string/app_name`
7. **Elimina carpetas inválidas** de recursos creadas en ejecuciones previas
8. Guarda configuración en `vmf_config.json` para referencia

### Build de flavors
```bash
# Build para un flavor específico
vmf build dev
vmf build prod
```

**¿Qué hace `vmf build`?**
- Lee la versión actual de `pubspec.yaml`
- Ejecuta build optimizado de Flutter con flags de producción:
  - `--flavor <flavor>` (flavor especificado)
  - `--release` (modo release)
  - `--obfuscate` (ofusca el código)
  - `--no-tree-shake-icons` (mantiene todos los íconos)
  - `--split-debug-info=./build/debug` (separa info de debug)
  - `--build-name` y `--build-number` desde pubspec.yaml
- Muestra resultado y errores del build

### Gestión de versiones
```bash
# Incrementar patch (por defecto): 1.0.0+1 → 1.0.1+2
vmf version

# Incrementar minor: 1.0.1+2 → 1.1.0+3
vmf version minor

# Incrementar major: 1.1.0+3 → 2.0.0+4
vmf version major
```

**¿Qué hace `vmf version`?**
- Si existe `version:` en pubspec.yaml, la incrementa según el tipo y suma 1 al build number
- Si no existe, la crea con valor inicial `version: 1.0.0+1`
- Mantiene formato semántico: `major.minor.patch+build`

## 🔧 Tecnologías y compatibilidad

- **Dart CLI** con dependencias mínimas
- **Configuración automática de Android**: Kotlin DSL (build.gradle.kts) y Groovy DSL (build.gradle)
- **Generación automática de keystores** usando keytool del sistema
- **Multiplataforma**: Windows (PowerShell), macOS, Linux
- **Detección inteligente** de sintaxis y estructura de archivos

### Soporte por plataforma:
- ✅ **Android**: Configuración completa (flavors, keystores, signing, manifests)
- ⚠️ **iOS**: Solo versionado y build básico (sin configuración de schemes/targets)
- ⚠️ **Web**: Solo versionado y build básico (sin configuración específica)
- ⚠️ **Desktop** (Windows/macOS/Linux): Solo versionado y build básico

## 📁 Estructura generada

Después de ejecutar `vmf init`, tu proyecto tendrá:

```
android/app/
├── build.gradle(.kts)          # Actualizado con flavors y signingConfigs
├── dev_keystore.jks            # Keystore generado para flavor dev
├── prod_keystore.jks           # Keystore generado para flavor prod
└── src/main/
    └── AndroidManifest.xml     # Actualizado para usar @string/app_name

vmf_config.json                 # Configuración de flavors guardada
```

## 🎯 Objetivo

Proporcionar una herramienta **profesional** y **automatizada** para la gestión completa de flavors y versionado en **Android Flutter**, eliminando la configuración manual propensa a errores y optimizando el flujo de desarrollo.

**Enfoque actual**: Configuración completa de Android con planes futuros para iOS, web y desktop.

## 🚀 Roadmap futuro

### Próximas características planeadas:
- 📱 **iOS**: Configuración automática de schemes, targets y Info.plist
- 🌐 **Web**: Configuración de diferentes entornos y builds
- 🖥️ **Desktop**: Configuración específica para Windows, macOS y Linux
- 🔄 **Configuración unificada**: Single source of truth para todos los flavors multiplataforma

## 🤝 Contribuciones

Este proyecto está diseñado para ser **publicado en pub.dev** como herramienta estándar de la comunidad Flutter.
