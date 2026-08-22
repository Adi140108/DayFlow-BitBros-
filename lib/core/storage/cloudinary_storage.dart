abstract class CloudinaryStorage {
  /// Uploads an image to Cloudinary and returns the secure URL
  Future<String> uploadImage(String filePath);

  /// Deletes an image from Cloudinary using its public identifier
  Future<void> deleteImage(String publicId);
}
