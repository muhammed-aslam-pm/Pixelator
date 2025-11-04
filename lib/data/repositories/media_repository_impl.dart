import 'package:pixelator/domain/entities/media_file_entity.dart';
import 'package:pixelator/domain/repositories/media_repository.dart';

import '../data_sources/media_remote_data_source.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDataSource remote;

  MediaRepositoryImpl(this.remote);

  @override
  Future<List<MediaFileEntity>> getCaseMedia(int caseId) async {
    final list = await remote.getCaseMedia(caseId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>> getPresignedUploadUrl(
    int caseId, {
    required String fileExtension,
    required String fileName,
    required String fileSizeMb,
    required String fileType,
    required String originalFileName,
  }) async {
    return await remote.getPresignedUploadUrl(caseId, {
      'file_extension': fileExtension,
      'file_name': fileName,
      'file_size_mb': fileSizeMb,
      'file_type': fileType,
      'original_file_name': originalFileName,
    });
  }

  @override
  Future<MediaFileEntity> confirmUpload(
    int caseId, {
    required String fileExtension,
    required String fileName,
    required String fileType,
    required String fileUuid,
    required String mimeType,
    required String objectKey,
    required String originalFileName,
  }) async {
    final model = await remote.confirmUpload(caseId, {
      'file_extension': fileExtension,
      'file_name': fileName,
      'file_type': fileType,
      'file_uuid': fileUuid,
      'mime_type': mimeType,
      'object_key': objectKey,
      'original_file_name': originalFileName,
    });
    return model.toEntity();
  }

  @override
  Future<void> uploadToPresignedUrl(
    String url,
    List<int> bytes,
    String contentType,
    void Function(int p, int t) onProgress,
  ) async {
    await remote.uploadToPresignedUrl(url, bytes, contentType, onProgress);
  }

  @override
  Future<void> deleteMediaFile(int caseId, int mediaFileId) async {
    await remote.deleteMediaFile(caseId, mediaFileId);
  }
}
