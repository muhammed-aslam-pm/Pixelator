class MediaFileEntity {
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

  const MediaFileEntity({
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
}

