import 'package:args/args.dart';

import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addCommand('init')
    ..addCommand('build')
    ..addCommand('version');

  final argResults = parser.parse(arguments);

  if (argResults.command == null) {
    print('''
vmf - Version Manager Flavors

Comandos disponibles:
  init                Inicializar flavors y configuración
  build <flavor>      Build para un flavor
  version [type]      Aumentar versión (type: patch|minor|major)
''');
    return;
  }

  switch (argResults.command!.name) {
    case 'init':
      _handleInit();
      break;
    case 'build':
      _handleBuild(argResults.command!);
      break;
    case 'version':
      _handleVersion(argResults.command!);
      break;
    default:
      print('Comando no reconocido. Usa vmf para ver ayuda.');
  }
}

void _handleInit() {
  print('[vmf] Ejecutando inicialización interactiva de flavors...');

  // Solicitar datos al usuario
  stdout.write('¿Cuántos flavors quieres configurar? ');
  final countStr = stdin.readLineSync();
  final count = int.tryParse(countStr ?? '') ?? 0;
  if (count <= 0) {
    print('Cantidad inválida. Cancelando.');
    return;
  }

  final flavors = <Map<String, String>>[];
  final flavorNames = <String>{};
  for (var i = 0; i < count; i++) {
    String? name;
    do {
      stdout.write('Nombre del flavor #${i + 1}: ');
      name = stdin.readLineSync();
      if (name == null || name.isEmpty) {
        print('Nombre inválido. Cancelando.');
        return;
      }
      if (flavorNames.contains(name)) {
        print('Ese flavor ya fue ingresado. Elige un nombre diferente.');
        name = null;
      }
    } while (name == null);
    flavorNames.add(name);
    stdout.write('Nombre de la app para el flavor "$name": ');
    final appName = stdin.readLineSync();
    if (appName == null || appName.isEmpty) {
      print('Nombre de app inválido. Cancelando.');
      return;
    }
    flavors.add({'name': name, 'app_name': appName});
  }

  // Guardar configuración en JSON
  final config = {
    'flavors': flavors,
    'created': DateTime.now().toIso8601String(),
  };
  final file = File('vmf_config.json');
  file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(config));
  print('[vmf] Configuración guardada en vmf_config.json');

  // === Lógica para modificar archivos del proyecto Flutter ===
  // 1. Buscar build.gradle.kts o build.gradle en android/app/
  final androidAppDir = Directory('android/app');
  if (!androidAppDir.existsSync()) {
    print(
      '[vmf] No se encontró la carpeta android/app. Ejecuta este comando en la raíz de tu proyecto Flutter.',
    );
    return;
  }
  final gradleKts = File('android/app/build.gradle.kts');
  final gradle = File('android/app/build.gradle');
  File? gradleFile;
  if (gradleKts.existsSync()) {
    gradleFile = gradleKts;
  } else if (gradle.existsSync()) {
    gradleFile = gradle;
  } else {
    print(
      '[vmf] No se encontró build.gradle.kts ni build.gradle en android/app/.',
    );
    return;
  }

  // 2. Leer y modificar el archivo gradle para agregar flavors y signingConfigs SOLO dentro de android { ... }
  // Hacer backup antes de modificar
  final backupPath = '${gradleFile.path}.bak';
  gradleFile.copySync(backupPath);
  print('[vmf] Backup creado: $backupPath');

  // Pedir datos para cada flavor
  final flavorsData = <Map<String, String>>[];
  final flavorKeys = <String, Map<String, String>>{};
  for (final flavor in flavors) {
    final name = flavor['name']!;
    stdout.write('Nombre de la app para el flavor "$name": ');
    final appName = stdin.readLineSync() ?? '';
    stdout.write('ApplicationId para "$name" (ej: com.tuempresa.app.$name): ');
    final appId = stdin.readLineSync() ?? '';
    stdout.write('Clave (password) para el keystore de "$name": ');
    final key = stdin.readLineSync() ?? '';
    stdout.write('Alias para el keystore de "$name" (default: ${name}_key): ');
    final alias = stdin.readLineSync();
    final password = key.isEmpty ? 'clave_$name' : key;
    final keyAlias = (alias == null || alias.isEmpty) ? '${name}_key' : alias;
    flavorKeys[name] = {'password': password, 'alias': keyAlias};
    flavorsData.add({
      'name': name,
      'app_name': appName,
      'application_id': appId,
    });
    // Generar el keystore real con keytool si no existe
    final keyFile = File('android/app/${name}_keystore.jks');
    if (!keyFile.existsSync()) {
      print('[vmf] Generando keystore para $name...');
      final keytoolCmd = [
        'keytool',
        '-genkeypair',
        '-v',
        '-keystore',
        keyFile.path,
        '-alias',
        keyAlias,
        '-keyalg',
        'RSA',
        '-keysize',
        '2048',
        '-validity',
        '10000',
        '-storepass',
        password,
        '-keypass',
        password,
        '-dname',
        'CN=$name, OU=vmf, O=vmf, L=City, S=State, C=AR',
      ];
      try {
        final result = Process.runSync(
          keytoolCmd.first,
          keytoolCmd.sublist(1),
          runInShell: true,
        );
        if (result.exitCode == 0) {
          print('[vmf] Keystore generado: ${keyFile.path}');
        } else {
          print('[vmf] Error generando keystore para $name:');
          print(result.stderr);
        }
      } catch (e) {
        print(
          '[vmf] No se pudo ejecutar keytool. Por favor, genera el keystore manualmente.',
        );
      }
    }
  }

  // Detectar si es Kotlin DSL (.kts) o Groovy DSL
  final isKts = gradleFile.path.endsWith('.kts');
  String gradleContent = gradleFile.readAsStringSync();

  // Encontrar el bloque android completo con balanceo de llaves
  final androidStart = gradleContent.indexOf('android {');
  if (androidStart == -1) {
    print(
      '[vmf] No se encontró el bloque android { ... } en el archivo gradle.',
    );
    return;
  }

  // Encontrar el final del bloque android balanceando llaves
  int braceCount = 0;
  int androidEnd = androidStart + 8; // posición después de "android {"
  for (int i = androidStart; i < gradleContent.length; i++) {
    if (gradleContent[i] == '{') braceCount++;
    if (gradleContent[i] == '}') {
      braceCount--;
      if (braceCount == 0) {
        androidEnd = i;
        break;
      }
    }
  }

  String androidBlock = gradleContent.substring(androidStart, androidEnd + 1);

  // Eliminar bloques previos generados por vmf
  androidBlock = androidBlock.replaceAll(
    RegExp(r'// VMF-BEGIN[\s\S]*?// VMF-END', multiLine: true),
    '',
  );
  // Eliminar TODOS los bloques signingConfigs, buildTypes, flavorDimensions, productFlavors existentes
  androidBlock = androidBlock.replaceAll(
    RegExp(
      r'signingConfigs\s*\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}',
      multiLine: true,
    ),
    '',
  );
  androidBlock = androidBlock.replaceAll(
    RegExp(r'buildTypes\s*\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', multiLine: true),
    '',
  );
  androidBlock = androidBlock.replaceAll(
    RegExp(r'flavorDimensions[^\n]*', multiLine: true),
    '',
  );
  androidBlock = androidBlock.replaceAll(
    RegExp(
      r'productFlavors\s*\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}',
      multiLine: true,
    ),
    '',
  );

  // Limpiar líneas vacías múltiples
  androidBlock = androidBlock.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

  // Generar nuevos bloques
  String signingConfigsBlock = '';
  String buildTypesBlock = '';
  String flavorDimensionsBlock = '';
  String productFlavorsBlock = '';

  if (isKts) {
    signingConfigsBlock =
        '    signingConfigs {\n' +
        flavorsData
            .map((flavor) {
              final name = flavor['name']!;
              final key = flavorKeys[name]!;
              return '        create("$name") {\n' +
                  '            storeFile = file("${name}_keystore.jks")\n' +
                  '            storePassword = "${key['password']}"\n' +
                  '            keyAlias = "${key['alias']}"\n' +
                  '            keyPassword = "${key['password']}"\n' +
                  '        }';
            })
            .join('\n') +
        '\n    }';

    buildTypesBlock =
        '    buildTypes {\n' +
        '        getByName("debug") {\n' +
        '            signingConfig = signingConfigs.getByName("${flavorsData[0]['name']}")\n' +
        '        }\n' +
        '        getByName("release") {\n' +
        '            signingConfig = signingConfigs.getByName("${flavorsData.last['name']}")\n' +
        '        }\n' +
        '    }';

    flavorDimensionsBlock = '    flavorDimensions += "env"';

    productFlavorsBlock =
        '    productFlavors {\n' +
        flavorsData
            .map(
              (flavor) =>
                  '        create("${flavor['name']}") {\n' +
                  '            dimension = "env"\n' +
                  '            applicationId = "${flavor['application_id']}"\n' +
                  '            resValue("string", "app_name", "${flavor['app_name']}")\n' +
                  '        }',
            )
            .join('\n') +
        '\n    }';
  } else {
    signingConfigsBlock =
        '    signingConfigs {\n' +
        flavorsData
            .map((flavor) {
              final name = flavor['name']!;
              final key = flavorKeys[name]!;
              return '        $name {\n' +
                  '            storeFile file("${name}_keystore.jks")\n' +
                  '            storePassword "${key['password']}"\n' +
                  '            keyAlias "${key['alias']}"\n' +
                  '            keyPassword "${key['password']}"\n' +
                  '        }';
            })
            .join('\n') +
        '\n    }';

    buildTypesBlock =
        '    buildTypes {\n' +
        '        debug {\n' +
        '            signingConfig signingConfigs.${flavorsData[0]['name']}\n' +
        '        }\n' +
        '        release {\n' +
        '            signingConfig signingConfigs.${flavorsData.last['name']}\n' +
        '        }\n' +
        '    }';

    flavorDimensionsBlock = '    flavorDimensions "env"';

    productFlavorsBlock =
        '    productFlavors {\n' +
        flavorsData
            .map(
              (flavor) =>
                  '        ${flavor['name']} {\n' +
                  '            dimension "env"\n' +
                  '            applicationId "${flavor['application_id']}"\n' +
                  '            resValue "string", "app_name", "${flavor['app_name']}"\n' +
                  '        }',
            )
            .join('\n') +
        '\n    }';
  }

  // Crear el bloque VMF completo
  final vmfBlock =
      '\n    // VMF-BEGIN\n' +
      '$signingConfigsBlock\n\n' +
      '$buildTypesBlock\n\n' +
      '$flavorDimensionsBlock\n\n' +
      '$productFlavorsBlock\n' +
      '    // VMF-END\n';

  // Insertar el bloque VMF antes de la última llave de cierre
  final lastBraceIndex = androidBlock.lastIndexOf('}');
  if (lastBraceIndex != -1) {
    androidBlock = androidBlock.substring(0, lastBraceIndex) + vmfBlock + '\n}';
  }

  // Reemplazar el bloque android completo en el contenido
  gradleContent =
      gradleContent.substring(0, androidStart) +
      androidBlock +
      gradleContent.substring(androidEnd + 1);

  gradleFile.writeAsStringSync(gradleContent);
  print(
    '[vmf] ${isKts ? 'build.gradle.kts' : 'build.gradle'} actualizado correctamente con flavors y signingConfigs.',
  );

  // 3. Eliminar carpetas values-{flavor} inválidas creadas anteriormente
  for (final flavor in flavors) {
    final flavorName = flavor['name']!;
    final invalidDir = Directory('android/app/src/main/res/values-$flavorName');
    if (invalidDir.existsSync()) {
      invalidDir.deleteSync(recursive: true);
      print('[vmf] Eliminada carpeta inválida: values-$flavorName');
    }
  }
  print(
    '[vmf] Los nombres de app se configuraron usando resValue en build.gradle',
  );

  // 4. Modificar AndroidManifest.xml para usar @string/app_name
  final manifestPath = 'android/app/src/main/AndroidManifest.xml';
  final manifestFile = File(manifestPath);
  if (manifestFile.existsSync()) {
    String manifestContent = manifestFile.readAsStringSync();
    // Reemplazar el label por @string/app_name (si no está)
    if (!manifestContent.contains('@string/app_name')) {
      manifestContent = manifestContent.replaceAll(
        RegExp(r'android:label="[^"]*"'),
        'android:label="@string/app_name"',
      );
      manifestFile.writeAsStringSync(manifestContent);
      print(
        '[vmf] AndroidManifest.xml actualizado para usar @string/app_name.',
      );
    } else {
      print('[vmf] AndroidManifest.xml ya usa @string/app_name.');
    }
  } else {
    print('[vmf] No se encontró AndroidManifest.xml.');
  }

  print('[vmf] Proceso de flavors automatizado finalizado.');
}

void _handleBuild(ArgResults results) {
  final args = results.rest;
  if (args.isEmpty) {
    print('Debes especificar el flavor. Ejemplo: vmf build dev');
    return;
  }
  final flavor = args[0];
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    print(
      '[vmf] No se encontró pubspec.yaml. Ejecuta este comando en la raíz de tu proyecto Flutter.',
    );
    return;
  }
  final versionLine = pubspec.readAsLinesSync().firstWhere(
    (l) => l.trim().startsWith('version:'),
    orElse: () => '',
  );
  if (versionLine.isEmpty) {
    print('[vmf] No se encontró la línea de versión en pubspec.yaml');
    return;
  }
  final versionMatch = RegExp(
    r'version:\s*(\d+\.\d+\.\d+)\+(\d+)',
  ).firstMatch(versionLine);
  if (versionMatch == null) {
    print('[vmf] Formato de versión no reconocido en pubspec.yaml');
    return;
  }
  final buildName = versionMatch.group(1)!;
  final buildNumber = versionMatch.group(2)!;

  // Comando de build con ofuscación y sin tree shake icons
  final buildCmd = [
    'flutter',
    'build',
    'apk',
    '--flavor',
    flavor,
    '--release',
    '--obfuscate',
    '--no-tree-shake-icons',
    '--split-debug-info=./build/debug',
    '--build-name=$buildName',
    '--build-number=$buildNumber',
  ];
  print('[vmf] Ejecutando build: ${buildCmd.join(' ')}');
  final result = Process.runSync(
    buildCmd.first,
    buildCmd.sublist(1),
    runInShell: true, // Importante para compatibilidad multiplataforma
  );
  print(result.stdout);
  if (result.exitCode != 0) {
    print('[vmf] Error en el build:');
    print(result.stderr);
  } else {
    print('[vmf] Build finalizado correctamente para flavor $flavor.');
  }
}

void _handleVersion(ArgResults results) {
  final args = results.rest;
  final type = args.isEmpty ? 'patch' : args[0];
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    print(
      '[vmf] No se encontró pubspec.yaml. Ejecuta este comando en la raíz de tu proyecto Flutter.',
    );
    return;
  }
  final lines = pubspec.readAsLinesSync();
  int versionIndex = lines.indexWhere((l) => l.trim().startsWith('version:'));
  String newVersion;
  if (versionIndex == -1) {
    // Si no existe la línea, crearla con 1.0.0+1
    newVersion = '1.0.0+1';
    lines.insert(0, 'version: $newVersion');
    pubspec.writeAsStringSync(lines.join('\n'));
    print(
      '[vmf] No se encontró línea de versión. Se agregó: version: $newVersion',
    );
    return;
  }
  final versionLine = lines[versionIndex];
  final versionMatch = RegExp(
    r'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)',
  ).firstMatch(versionLine);
  if (versionMatch == null) {
    print('[vmf] Formato de versión no reconocido en pubspec.yaml');
    return;
  }
  int major = int.parse(versionMatch.group(1)!);
  int minor = int.parse(versionMatch.group(2)!);
  int patch = int.parse(versionMatch.group(3)!);
  int build = int.parse(versionMatch.group(4)!);

  switch (type) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
      break;
    case 'minor':
      minor++;
      patch = 0;
      break;
    default:
      patch++;
  }
  build++;
  newVersion = '$major.$minor.$patch+$build';
  lines[versionIndex] = 'version: $newVersion';
  pubspec.writeAsStringSync(lines.join('\n'));
  print('[vmf] Nueva versión: $newVersion');
}
