# Changelog

## 1.0.0

### ✨ Initial Release

**vmf** (Version Manager Flavors) - Professional CLI tool for automated Flutter flavors and versioning management.

#### 🚀 Features

- **Interactive flavor initialization** (`vmf init`)
  - Smart detection of Kotlin DSL (.kts) vs Groovy DSL syntax
  - Automatic keystore generation using system keytool
  - Intelligent build.gradle modification with duplicate cleanup
  - Automatic backup creation (.bak files)
  - VMF markers for generated blocks identification

- **Optimized flavor builds** (`vmf build <flavor>`)
  - Production-ready flags: --obfuscate, --no-tree-shake-icons
  - Automatic version reading from pubspec.yaml
  - Cross-platform compatibility (Windows, macOS, Linux)
  - Comprehensive error reporting

- **Semantic versioning management** (`vmf version [patch|minor|major]`)
  - Automatic version increment with build number
  - Creates version line if not exists (1.0.0+1)
  - Direct pubspec.yaml modification

#### 🔧 Technical Features

- **Android complete support**: build.gradle(.kts), keystores, signing configs, manifests
- **Cross-platform compatibility**: Windows PowerShell, macOS, Linux
- **Intelligent syntax detection**: Handles both Kotlin DSL and Groovy DSL
- **Automatic cleanup**: Removes invalid resource directories and duplicated blocks
- **Professional configuration**: Uses resValue for app names instead of invalid resource folders

#### 📱 Platform Support

- ✅ **Android**: Complete configuration (flavors, keystores, signing, manifests)
- ⚠️ **iOS**: Basic versioning and build only
- ⚠️ **Web**: Basic versioning and build only  
- ⚠️ **Desktop**: Basic versioning and build only

#### 🎯 Use Cases

Perfect for Flutter developers who need:
- Automated Android flavor management
- Professional signing and keystore handling
- Semantic versioning workflow
- Production-ready build automation
- Clean, error-free build.gradle maintenance

#### 📦 Installation

```bash
dart pub global activate vmf
```

#### 🚀 Quick Start

```bash
# Initialize flavors in your Flutter project
vmf init

# Build for specific flavor
vmf build dev

# Increment version
vmf version patch
```
