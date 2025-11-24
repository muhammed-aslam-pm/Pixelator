import 'dart:io';
import 'package:image/image.dart' as img;

class PerspectiveCorrector {
  /// Applies perspective correction to the captured image
  /// targetRect is in normalized coordinates (0.0 to 1.0)
  Future<String> correctPerspective(
    String inputPath,
    String outputPath, {
    double targetLeft = 0.2,
    double targetTop = 0.25,
    double targetRight = 0.8,
    double targetBottom = 0.75,
  }) async {
    final imageFile = File(inputPath);
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Failed to decode image');
    final width = image.width;
    final height = image.height;

    final cropLeft = (targetLeft * width).toInt();
    final cropTop = (targetTop * height).toInt();
    final cropWidth = ((targetRight - targetLeft) * width).toInt();
    final cropHeight = ((targetBottom - targetTop) * height).toInt();

    final cropped = img.copyCrop(
      image,
      x: cropLeft,
      y: cropTop,
      width: cropWidth,
      height: cropHeight,
    );

    // rest as you had before
    final sharpened = img.convolution(
      cropped,
      filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
    );
    final enhanced = img.adjustColor(
      sharpened,
      contrast: 1.1,
      brightness: 1.05,
    );
    final correctedBytes = img.encodeJpg(enhanced, quality: 95);
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(correctedBytes);

    return outputPath;
  }
}
