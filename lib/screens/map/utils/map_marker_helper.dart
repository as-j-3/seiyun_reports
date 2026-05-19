import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerHelper {
  static Future<BitmapDescriptor> getMarkerIconFromIcon(
    IconData iconData,
    Color color,
    double size,
  ) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double iconSize = size;

    // Rotate canvas 180 degrees to fix the "upside down" issue
    canvas.translate(iconSize / 2, iconSize / 2);
    canvas.rotate(math.pi);
    canvas.translate(-iconSize / 2, -iconSize / 2);
    
    // Draw background circle for better visibility
    final Paint paint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(iconSize / 2, iconSize / 2), iconSize / 2, paint);
    
    // Draw border
    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(Offset(iconSize / 2, iconSize / 2), iconSize / 2, borderPaint);

    final TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: iconSize * 0.65,
        fontFamily: iconData.fontFamily,
        color: color,
        package: iconData.fontPackage,
      ),
    );
    
    textPainter.layout();
    
    // Position correctly to avoid clipping and flipping issues
    textPainter.paint(
      canvas,
      Offset(
        (iconSize - textPainter.width) / 2,
        (iconSize - textPainter.height) / 2,
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
          iconSize.toInt(),
          iconSize.toInt(),
        );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}
