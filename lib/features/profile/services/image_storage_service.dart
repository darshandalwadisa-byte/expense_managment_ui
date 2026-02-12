import 'dart:io';
import 'package:expense/core/utils/app_logger.dart';
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      AppLogger.info('Saving profile image locally for user: $userId');

      // Get the app's documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Create a profile_images directory if it doesn't exist
      final Directory profileImagesDir = Directory(
        '${appDir.path}/profile_images',
      );
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      // Create user-specific directory
      final Directory userDir = Directory('${profileImagesDir.path}/$userId');
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }

      // Define the file path
      const String fileName = 'profile.jpg';
      final String localPath = '${userDir.path}/$fileName';

      // Copy the image file to the local directory
      final File newImage = await imageFile.copy(localPath);

      AppLogger.info('Profile image saved locally: $localPath');
      return newImage.path;
    } catch (e, stack) {
      AppLogger.error('Local Storage Error', e, stack);
      throw 'Failed to save image locally: $e';
    }
  }

  /// Delete profile image from local storage
  Future<void> deleteProfileImage(String userId) async {
    try {
      AppLogger.info('Deleting local profile image for user: $userId');

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDir.path}/profile_images/$userId/profile.jpg';

      final File imageFile = File(filePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        AppLogger.info('Profile image deleted successfully');
      }
    } catch (e, stack) {
      AppLogger.error('Delete Error', e, stack);
      throw 'Failed to delete image: $e';
    }
  }

  /// Get profile image path from local storage
  Future<String?> getProfileImagePath(String userId) async {
    try {
      AppLogger.info('Getting local profile image path for user: $userId');

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDir.path}/profile_images/$userId/profile.jpg';

      final File imageFile = File(filePath);
      if (await imageFile.exists()) {
        AppLogger.info('Profile image found: $filePath');
        return filePath;
      }

      AppLogger.info('No profile image found');
      return null;
    } catch (e, stack) {
      AppLogger.error('Get Path Error', e, stack);
      return null;
    }
  }
}
