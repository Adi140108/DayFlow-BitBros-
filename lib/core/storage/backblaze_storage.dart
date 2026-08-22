abstract class BackblazeStorage {
  /// Uploads a document (like a PDF) to Backblaze B2, scoped by organizationId
  Future<String> uploadDocument(String filePath, String organizationId);

  /// Retrieves the secure download URL for a document
  Future<String> getDocumentUrl(String objectId, String organizationId);

  /// Deletes a document from Backblaze B2
  Future<void> deleteDocument(String objectId, String organizationId);
}
