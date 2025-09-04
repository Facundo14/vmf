# Changelog

## 1.0.2

### ✨ Enhanced Example and Documentation

#### 🚀 New Features
- **Complete example project** with Flutter project structure simulation
- **Interactive demo scripts** for Windows PowerShell and Unix systems
- **Comprehensive example documentation** with step-by-step tutorial
- **Real-world use case scenarios** (dev/prod flavors setup)

#### 📚 Documentation Improvements
- **Professional example directory** structure in `example/`
- **Detailed before/after comparisons** showing vmf impact
- **Script demonstrations** showing complete workflow
- **Enhanced pub.dev presentation** with example tab

#### 🔧 Technical Enhancements
- **Better pub.dev scoring** with comprehensive examples
- **Issue tracker** link added to pubspec.yaml
- **Improved package discoverability** through examples

#### 📦 Example Contents
- `example/README.md` - Complete tutorial and documentation
- `example/vmf_demo.sh` - Demo script for Linux/macOS
- `example/vmf_demo.ps1` - Demo script for Windows PowerShell
- `example/flutter_project/` - Simulated Flutter project structure

Perfect for developers who want to see vmf in action before implementing in their projects.

## 1.0.1

### 📚 Documentation and Example Addition

#### 🚀 New Features
- **Complete example project** demonstrating vmf usage
- **Step-by-step tutorial** with real project structure
- **Demo scripts** for multiple platforms

#### 🔧 Improvements
- **Enhanced pub.dev presentation** with examples
- **Better documentation** structure
- **Professional package presentation**

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
