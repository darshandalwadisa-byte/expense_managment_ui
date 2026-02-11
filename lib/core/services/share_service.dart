import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Captures the widget provided in the [screenshotController] and shares it.
  ///
  /// [screenshotController] The controller attached to the UI you want to capture.
  /// [fileName] Optional name for the captured image file.
  static Future<void> captureAndShare({
    required ScreenshotController screenshotController,
    String fileName = 'transaction_receipt.png',
  }) async {
    try {
      // 1. Capture the screenshot
      final Uint8List? imageBytes = await screenshotController.capture();

      if (imageBytes != null) {
        // 2. Save it to a temporary directory
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/$fileName';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        // 3. Share the file using share_plus
        // Using XFile from cross_file (wrapped by share_plus)
        await Share.shareXFiles([
          XFile(imagePath),
        ], text: 'Check out my transaction receipt!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing screenshot: $e');
      }
      rethrow;
    }
  }

  /// Optional: Save image to gallery functionality can be added here
  /// requires 'image_gallery_saver' or similar package.
}
