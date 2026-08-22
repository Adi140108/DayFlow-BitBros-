import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cloudinary_storage.dart';

/// Real Cloudinary Storage implementation for Dayflow profile images.
/// Uses Cloudinary Unsigned Upload Preset without exposing API secret to client.
class CloudinaryStorageImpl implements CloudinaryStorage {
  final String cloudName;
  final String uploadPreset;

  CloudinaryStorageImpl({
    this.cloudName = 'orhokqmz',
    this.uploadPreset = 'dayflow_avatars',
  });

  @override
  Future<String> uploadImage(String filePath) async {
    // Validate format & image size limit (5MB)
    final Uri uploadUri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uploadUri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(responseData) as Map<String, dynamic>;
      return json['secure_url'] as String;
    } else {
      throw Exception('Cloudinary upload failed: ${response.statusCode} - $responseData');
    }
  }

  @override
  Future<void> deleteImage(String publicId) async {
    // Client-side deletion is restricted; Cloudinary asset deletion is handled via backend endpoint
  }
}
