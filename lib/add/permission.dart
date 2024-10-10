import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  // Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      print('Camera permission denied.'); // Logging for debugging
    } else if (status.isPermanentlyDenied) {
      // If the user has permanently denied the permission, provide an option to open settings
      openAppSettings();
      print(
          'Camera permission permanently denied. Open settings to enable it.');
    }

    return false; // Return false if permission is denied or permanently denied
  }

  // Request gallery permission (platform-specific)
  Future<bool> requestGalleryPermission() async {
    PermissionStatus status;

    if (Platform.isIOS) {
      status = await Permission.photos.request(); // iOS specific
    } else {
      status = await Permission.storage.request(); // Android specific
    }

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      print('Gallery permission denied.'); // Logging for debugging
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      print(
          'Gallery permission permanently denied. Open settings to enable it.');
    }

    return false; // Return false if permission is denied or permanently denied
  }

  // Check permissions
  Future<bool> checkPermissions() async {
    bool cameraGranted = await requestCameraPermission();
    bool galleryGranted = await requestGalleryPermission();

    // You can log or handle the permission results here if needed
    return cameraGranted && galleryGranted;
  }
}
