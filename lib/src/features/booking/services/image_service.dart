import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;
    PermissionStatus status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo library permission
  static Future<bool> requestGalleryPermission() async {
    if (kIsWeb) return true;
    PermissionStatus status = await Permission.photos.request();
    // On Android 13+ (SDK 33), READ_MEDIA_IMAGES might be needed, but photos usually handles it.
    if (status.isDenied) {
      // Fallback or retry logic if needed, but for now simpe check
    }
    return status.isGranted || await Permission.mediaLibrary.isGranted;
  }

  /// Pick image and return compressed Base64 string
  static Future<String?> pickImageBase64({required bool fromCamera}) async {
    try {
      bool hasPermission = fromCamera
          ? await requestCameraPermission()
          : await requestGalleryPermission();

      if (!hasPermission) {
        // Simple fallback: ImagePicker might handle permission itself
        // but explicit check is safer for custom logic
      }

      // 1. Pick Image
      // We use maxWidth/maxHeight here as a first line of defense
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70, // Initial quality
      );

      if (image == null) return null;

      // 2. Compress & Convert to Base64
      Uint8List bytes;

      if (kIsWeb) {
        // Web: pickImage already returns bytes roughly resizing if supported.
        // flutter_image_compress_web can be used, but image.readAsBytes is simplest.
        bytes = await image.readAsBytes();
      } else {
        // Mobile: Use FlutterImageCompress for better control
        // Note: XFile from image_picker is already compressed by imageQuality: 70
        // But we want to ensure it's small enough for Firestore (< 800KB safe margin)

        final Uint8List? compressedBytes =
            await FlutterImageCompress.compressWithFile(
              image.path,
              minWidth: 600,
              minHeight: 600,
              quality: 50, // Aggressive compression for Base64 storage
            );

        if (compressedBytes == null) {
          // Fallback to original if compression fails
          bytes = await image.readAsBytes();
        } else {
          bytes = compressedBytes;
        }
      }

      // 3. Final Check on Size (Firestore Limit 1MB)
      // Base64 overhead is ~33%. So 700KB binary ~= 1MB Base64.
      // Let's aim for < 500KB binary.
      if (bytes.lengthInBytes > 700 * 1024) {
        // If still too big, we might skip or warn.
        // For prototype, we assume the aggressive compression works.
        debugPrint(
          "Warning: Image size ${bytes.lengthInBytes} large for Base64 storage",
        );
      }

      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }
}
