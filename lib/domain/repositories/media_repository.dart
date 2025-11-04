import '../entities/media_file_entity.dart';

abstract class MediaRepository {
  Future<List<MediaFileEntity>> getCaseMedia(int caseId);
  Future<Map<String, dynamic>> getPresignedUploadUrl(int caseId, {
    required String fileExtension,
    required String fileName,
    required String fileSizeMb,
    required String fileType,
    required String originalFileName,
  });
  Future<MediaFileEntity> confirmUpload(int caseId, {
    required String fileExtension,
    required String fileName,
    required String fileType,
    required String fileUuid,
    required String mimeType,
    required String objectKey,
    required String originalFileName,
  });
  Future<void> uploadToPresignedUrl(String url, List<int> bytes, String contentType, void Function(int, int) onProgress);
}

