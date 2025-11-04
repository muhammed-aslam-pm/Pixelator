import 'package:dio/dio.dart';
import '../models/media_file_model.dart';

abstract class MediaRemoteDataSource {
  Future<List<MediaFileModel>> getCaseMedia(int caseId);
  Future<Map<String, dynamic>> getPresignedUploadUrl(
    int caseId,
    Map<String, dynamic> payload,
  );
  Future<MediaFileModel> confirmUpload(
    int caseId,
    Map<String, dynamic> payload,
  );
  Future<void> uploadToPresignedUrl(
    String url,
    List<int> bytes,
    String contentType,
    void Function(int, int) onProgress,
  );
  Future<void> deleteMediaFile(int caseId, int mediaFileId);
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final Dio dio;

  MediaRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MediaFileModel>> getCaseMedia(int caseId) async {
    final resp = await dio.get('/api/v1/cases/$caseId/media');
    final List<dynamic> data = resp.data as List<dynamic>;
    return data
        .map((e) => MediaFileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getPresignedUploadUrl(
    int caseId,
    Map<String, dynamic> payload,
  ) async {
    final resp = await dio.post(
      '/api/v1/cases/$caseId/media/upload-url',
      data: payload,
    );
    return resp.data as Map<String, dynamic>;
  }

  @override
  Future<MediaFileModel> confirmUpload(
    int caseId,
    Map<String, dynamic> payload,
  ) async {
    final resp = await dio.post(
      '/api/v1/cases/$caseId/media/confirm-upload',
      data: payload,
    );
    return MediaFileModel.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<void> uploadToPresignedUrl(
    String url,
    List<int> bytes,
    String contentType,
    void Function(int, int) onProgress,
  ) async {
    final putDio = Dio(BaseOptions(headers: {'Content-Type': contentType}));
    await putDio.put(url, data: bytes, onSendProgress: onProgress);
  }

  @override
  Future<void> deleteMediaFile(int caseId, int mediaFileId) async {
    await dio.delete('/api/v1/cases/$caseId/media/$mediaFileId');
  }
}
