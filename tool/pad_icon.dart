import 'dart:io';
import 'package:image/image.dart' as img;

// Ejecuta con: dart run tool/pad_icon.dart
// Lee assets/icons/app_icon.png, añade padding transparente y guarda en assets/icons/app_icon_splash.png
void main() {
  const inputPath = 'assets/icons/app_icon.png';
  const outputPath = 'assets/icons/app_icon_splash.png';

  if (!File(inputPath).existsSync()) {
    stderr.writeln('No se encontró $inputPath');
    exit(1);
  }

  final bytes = File(inputPath).readAsBytesSync();
  final original = img.decodeImage(bytes);
  if (original == null) {
    stderr.writeln('No se pudo decodificar $inputPath');
    exit(1);
  }

  // Factor de padding: 25% del tamaño resultante en cada lado
  // Resultado: el gráfico ocupa ~50% área, evitando recortes en Android 12
  const canvasSize = 1024; // tamaño cuadrado de salida
  const paddingRatio = 0.15; // 15% por lado (icono más grande)

  final canvas = img.Image(width: canvasSize, height: canvasSize);
  // Fondo totalmente transparente
  img.fill(canvas, color: img.ColorUint8.rgba(0, 0, 0, 0));

  // Calcular tamaño máximo del icono dentro del canvas respetando padding
  final maxContent = (canvasSize * (1 - paddingRatio * 2)).toInt();
  // Escalar manteniendo proporción para que quepa dentro de maxContent
  final scale = {'w': maxContent / original.width, 'h': maxContent / original.height};
  final factor = scale['w']! < scale['h']! ? scale['w']! : scale['h']!;
  final targetW = (original.width * factor).toInt();
  final targetH = (original.height * factor).toInt();
  final resized = img.copyResize(original, width: targetW, height: targetH, interpolation: img.Interpolation.linear);

  // Centrar
  final dx = ((canvasSize - targetW) / 2).round();
  final dy = ((canvasSize - targetH) / 2).round();
  img.compositeImage(canvas, resized, dstX: dx, dstY: dy);

  final outBytes = img.encodePng(canvas);
  File(outputPath).writeAsBytesSync(outBytes);
  stdout.writeln('Generado $outputPath (${canvas.width}x${canvas.height})');
}
