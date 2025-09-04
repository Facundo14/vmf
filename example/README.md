# vmf Example

Este ejemplo muestra cómo usar **vmf** en un proyecto Flutter real para configurar flavors automáticamente.

## 📂 Estructura del Proyecto

Este ejemplo simula un proyecto Flutter típico con:
- Desarrollo (`dev`) y Producción (`prod`) flavors
- Configuración automática de Android
- Gestión de versiones semántica

## 🚀 Pasos del Ejemplo

### 1. Instalar vmf
```bash
dart pub global activate vmf
```

### 2. Inicializar flavors
```bash
vmf init
```

**Configuración sugerida para este ejemplo:**
- Cantidad de flavors: `2`
- Flavor 1: 
  - Nombre: `dev`
  - App name: `MyApp Dev`
  - ApplicationId: `com.example.myapp.dev`
  - Keystore password: `devpass123`
  - Key alias: `dev_key`
- Flavor 2:
  - Nombre: `prod`
  - App name: `MyApp`
  - ApplicationId: `com.example.myapp`
  - Keystore password: `prodpass456`
  - Key alias: `prod_key`

### 3. Resultado esperado

Después de `vmf init`, tu proyecto tendrá:

```
android/app/
├── build.gradle.kts          # ✅ Actualizado con flavors
├── dev_keystore.jks          # ✅ Generado automáticamente
├── prod_keystore.jks         # ✅ Generado automáticamente
└── src/main/
    └── AndroidManifest.xml   # ✅ Usa @string/app_name

vmf_config.json               # ✅ Configuración guardada
```

### 4. Build para diferentes flavors
```bash
# Build desarrollo
vmf build dev

# Build producción
vmf build prod
```

### 5. Gestión de versiones
```bash
# Versión patch: 1.0.0+1 → 1.0.1+2
vmf version

# Versión minor: 1.0.1+2 → 1.1.0+3
vmf version minor

# Versión major: 1.1.0+3 → 2.0.0+4
vmf version major
```

## 📱 Archivos generados por vmf

### android/app/build.gradle.kts
```kotlin
android {
    // ... configuración existente ...

    // VMF-BEGIN
    signingConfigs {
        create("dev") {
            storeFile = file("dev_keystore.jks")
            storePassword = "devpass123"
            keyAlias = "dev_key"
            keyPassword = "devpass123"
        }
        create("prod") {
            storeFile = file("prod_keystore.jks")
            storePassword = "prodpass456"
            keyAlias = "prod_key"
            keyPassword = "prodpass456"
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("dev")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("prod")
        }
    }

    flavorDimensions += "env"

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationId = "com.example.myapp.dev"
            resValue("string", "app_name", "MyApp Dev")
        }
        create("prod") {
            dimension = "env"
            applicationId = "com.example.myapp"
            resValue("string", "app_name", "MyApp")
        }
    }
    // VMF-END
}
```

### vmf_config.json
```json
{
  "flavors": [
    {
      "name": "dev",
      "app_name": "MyApp Dev"
    },
    {
      "name": "prod", 
      "app_name": "MyApp"
    }
  ],
  "created": "2025-09-04T..."
}
```

## 🎯 Beneficios de este flujo

1. **Automatización completa**: Sin edición manual de build.gradle
2. **Keystores seguros**: Generados automáticamente con credenciales únicas
3. **Sin duplicados**: vmf limpia configuraciones previas
4. **Multiplataforma**: Funciona en Windows, macOS, Linux
5. **Versionado semántico**: Gestión profesional de versiones

## ⚠️ Notas importantes

- **Backup automático**: vmf crea `.bak` antes de modificar archivos
- **Solo Android**: Configuración completa solo para Android (por ahora)
- **Limpieza automática**: Elimina configuraciones inválidas previas
- **Sintaxis inteligente**: Detecta Kotlin DSL vs Groovy DSL automáticamente

## 🔄 Flujo de trabajo recomendado

```bash
# 1. Configurar proyecto una vez
vmf init

# 2. Desarrollar features
# ... código ...

# 3. Incrementar versión cuando sea necesario
vmf version patch

# 4. Build para testing
vmf build dev

# 5. Build para producción
vmf build prod

# 6. Repetir desde paso 2
```

¡Con vmf, la gestión de flavors y versiones en Flutter es completamente automatizada! 🚀
