import 'dart:convert';
import 'dart:typed_data';

/// Utilities for image encoding, decoding, and compression.
///
/// Used primarily for profile photo handling, where images are captured
/// from the camera, optionally compressed, and stored as base64 strings
/// for API transmission.
class ImageUtils {
  ImageUtils._();

  /// Encodes raw image bytes to a base64 string.
  static String bytesToBase64(Uint8List bytes) => base64Encode(bytes);

  /// Decodes a base64 string back to raw image bytes.
  static Uint8List base64ToBytes(String base64String) =>
      base64Decode(base64String);

  /// Compresses an image represented as raw bytes.
  ///
  /// TODO: Implement real compression in Phase 4 using flutter_image_compress.
  /// Currently returns the input bytes unchanged.
  static Future<Uint8List> compressImage(Uint8List bytes) async => bytes;
}
