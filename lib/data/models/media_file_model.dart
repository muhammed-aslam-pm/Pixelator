import 'package:pixelator/domain/entities/media_file_entity.dart';

class MediaFileModel {
  final int mediaFileId;
  final String mediaFileUuid;
  final int caseId;
  final String fileName;
  final String originalFileName;
  final String fileType;
  final String mimeType;
  final String fileExtension;
  final String? s3Url;
  final String processingStatus;
  final DateTime? createdAt;

  MediaFileModel({
    required this.mediaFileId,
    required this.mediaFileUuid,
    required this.caseId,
    required this.fileName,
    required this.originalFileName,
    required this.fileType,
    required this.mimeType,
    required this.fileExtension,
    required this.s3Url,
    required this.processingStatus,
    required this.createdAt,
  });

  factory MediaFileModel.fromJson(Map<String, dynamic> json) {
    return MediaFileModel(
      mediaFileId: json['media_file_id'] as int,
      mediaFileUuid: json['media_file_uuid'] as String,
      caseId: json['case_id'] as int,
      fileName: json['file_name'] as String,
      originalFileName: json['original_file_name'] as String,
      fileType: json['file_type'] as String,
      mimeType: json['mime_type'] as String,
      fileExtension: json['file_extension'] as String,
      s3Url: json['s3_url'] as String?,
      processingStatus: json['processing_status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  MediaFileEntity toEntity() => MediaFileEntity(
        mediaFileId: mediaFileId,
        mediaFileUuid: mediaFileUuid,
        caseId: caseId,
        fileName: fileName,
        originalFileName: originalFileName,
        fileType: fileType,
        mimeType: mimeType,
        fileExtension: fileExtension,
        s3Url: s3Url,
        processingStatus: processingStatus,
        createdAt: createdAt,
      );
}

