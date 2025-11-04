import '../entities/media_file_entity.dart';
import '../repositories/media_repository.dart';

class GetCaseMediaUseCase {
  final MediaRepository repo;
  GetCaseMediaUseCase(this.repo);
  Future<List<MediaFileEntity>> call(int caseId) => repo.getCaseMedia(caseId);
}

class GetPresignedUrlUseCase {
  final MediaRepository repo;
  GetPresignedUrlUseCase(this.repo);
  Future<Map<String, dynamic>> call(
    int caseId, {
    required String fileExtension,
    required String fileName,
    required String fileSizeMb,
    required String fileType,
    required String originalFileName,
  }) => repo.getPresignedUploadUrl(
    caseId,
    fileExtension: fileExtension,
    fileName: fileName,
    fileSizeMb: fileSizeMb,
    fileType: fileType,
    originalFileName: originalFileName,
  );
}

class ConfirmUploadUseCase {
  final MediaRepository repo;
  ConfirmUploadUseCase(this.repo);
  Future<MediaFileEntity> call(
    int caseId, {
    required String fileExtension,
    required String fileName,
    required String fileType,
    required String fileUuid,
    required String mimeType,
    required String objectKey,
    required String originalFileName,
  }) => repo.confirmUpload(
    caseId,
    fileExtension: fileExtension,
    fileName: fileName,
    fileType: fileType,
    fileUuid: fileUuid,
    mimeType: mimeType,
    objectKey: objectKey,
    originalFileName: originalFileName,
  );
}

class UploadToS3UseCase {
  final MediaRepository repo;
  UploadToS3UseCase(this.repo);
  Future<void> call(
    String url,
    List<int> bytes,
    String contentType,
    void Function(int, int) onProgress,
  ) => repo.uploadToPresignedUrl(url, bytes, contentType, onProgress);
}

class DeleteMediaFileUseCase {
  final MediaRepository repo;

  DeleteMediaFileUseCase(this.repo);

  Future<void> call(int caseId, int mediaFileId) =>
      repo.deleteMediaFile(caseId, mediaFileId);
}
