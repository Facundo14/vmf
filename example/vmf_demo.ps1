# vmf_example_demo.ps1
# Script de demostración de vmf para Windows PowerShell

Write-Host "🚀 Demostración de vmf (Version Manager Flavors)" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📂 Estructura inicial del proyecto Flutter:" -ForegroundColor Yellow
Write-Host "flutter_project/"
Write-Host "├── pubspec.yaml"
Write-Host "└── android/app/"
Write-Host "    ├── build.gradle.kts  (sin flavors)"
Write-Host "    └── src/main/"
Write-Host "        └── AndroidManifest.xml"
Write-Host ""

Write-Host "💡 Paso 1: Instalar vmf" -ForegroundColor Green
Write-Host "PS> dart pub global activate vmf" -ForegroundColor Gray
Write-Host ""

Write-Host "🔧 Paso 2: Inicializar flavors" -ForegroundColor Green
Write-Host "PS> cd flutter_project" -ForegroundColor Gray
Write-Host "PS> vmf init" -ForegroundColor Gray
Write-Host ""
Write-Host "Respuestas del ejemplo:" -ForegroundColor White
Write-Host "¿Cuántos flavors? 2" -ForegroundColor DarkGray
Write-Host "Flavor #1: dev" -ForegroundColor DarkGray
Write-Host "App name: MyApp Dev" -ForegroundColor DarkGray
Write-Host "ApplicationId: com.example.myapp.dev" -ForegroundColor DarkGray
Write-Host "Password: devpass123" -ForegroundColor DarkGray
Write-Host "Alias: dev_key" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Flavor #2: prod" -ForegroundColor DarkGray
Write-Host "App name: MyApp" -ForegroundColor DarkGray
Write-Host "ApplicationId: com.example.myapp" -ForegroundColor DarkGray
Write-Host "Password: prodpass456" -ForegroundColor DarkGray
Write-Host "Alias: prod_key" -ForegroundColor DarkGray
Write-Host ""

Write-Host "✅ Resultado después de vmf init:" -ForegroundColor Green
Write-Host "flutter_project/"
Write-Host "├── pubspec.yaml"
Write-Host "├── vmf_config.json           ← ✨ Nuevo" -ForegroundColor Yellow
Write-Host "└── android/app/"
Write-Host "    ├── build.gradle.kts      ← ✅ Actualizado con flavors" -ForegroundColor Green
Write-Host "    ├── build.gradle.kts.bak  ← 🔒 Backup automático" -ForegroundColor Blue
Write-Host "    ├── dev_keystore.jks      ← ✨ Generado automáticamente" -ForegroundColor Yellow
Write-Host "    ├── prod_keystore.jks     ← ✨ Generado automáticamente" -ForegroundColor Yellow
Write-Host "    └── src/main/"
Write-Host "        └── AndroidManifest.xml ← ✅ Usa @string/app_name" -ForegroundColor Green
Write-Host ""

Write-Host "🏗️ Paso 3: Build para diferentes flavors" -ForegroundColor Green
Write-Host "PS> vmf build dev    # Build de desarrollo" -ForegroundColor Gray
Write-Host "PS> vmf build prod   # Build de producción" -ForegroundColor Gray
Write-Host ""

Write-Host "📈 Paso 4: Gestión de versiones" -ForegroundColor Green
Write-Host "PS> vmf version      # 1.0.0+1 → 1.0.1+2" -ForegroundColor Gray
Write-Host "PS> vmf version minor # 1.0.1+2 → 1.1.0+3" -ForegroundColor Gray
Write-Host "PS> vmf version major # 1.1.0+3 → 2.0.0+4" -ForegroundColor Gray
Write-Host ""

Write-Host "🎯 Beneficios logrados:" -ForegroundColor Magenta
Write-Host "✅ Configuración Android automatizada" -ForegroundColor Green
Write-Host "✅ Keystores seguros generados automáticamente" -ForegroundColor Green
Write-Host "✅ Sin duplicados en build.gradle" -ForegroundColor Green
Write-Host "✅ Backup automático de archivos" -ForegroundColor Green
Write-Host "✅ Gestión semántica de versiones" -ForegroundColor Green
Write-Host "✅ Builds optimizados con flags de producción" -ForegroundColor Green
Write-Host ""

Write-Host "🎉 ¡Tu proyecto Flutter tiene flavors profesionales!" -ForegroundColor Cyan
Write-Host "Ahora puedes desarrollar con 'dev' y publicar con 'prod' fácilmente." -ForegroundColor White
