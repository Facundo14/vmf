/// vmf library
///
/// Librería pública mínima expuesta por el paquete `vmf`.
/// Actualmente contiene utilidades pequeñas usadas por la CLI. Documentar
/// la API pública ayuda a mejorar la puntuación en pub.dev.
///
/// Calcula un valor de ejemplo usado por los tests y demos.
///
/// Retorna 42 (6 * 7). Esta función es intencionalmente simple y sirve como
/// demostración de cómo documentar la API pública del paquete.
///
/// Ejemplo:
/// ```dart
/// import 'package:vmf/vmf.dart';
///
/// void main() {
///   print(calculate()); // 42
/// }
/// ```
int calculate() {
  return 6 * 7;
}
