import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/media_file_entity.dart';
import '../../domain/usecases/media_usecases.dart';

part 'case_media_state.dart';

class CaseMediaCubit extends Cubit<CaseMediaState> {
  final GetCaseMediaUseCase getMedia;
  final GetPresignedUrlUseCase getPresigned;
  final UploadToS3UseCase uploadToS3;
  final ConfirmUploadUseCase confirmUpload;

  CaseMediaCubit(this.getMedia, this.getPresigned, this.uploadToS3, this.confirmUpload)
      : super(const CaseMediaState());

  Future<void> fetch(int caseId) async {
    emit(state.copyWith(loading: true));
    try {
      final items = await getMedia(caseId);
      emit(state.copyWith(loading: false, items: items));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> uploadImages(int caseId, List<XFile> files) async {
    for (final file in files) {
      final String fileName = file.name;
      final String ext = fileName.contains('.') ? fileName.split('.').last : 'png';
      final String mimeType = _inferMime(ext);
      final int sizeBytes = await file.length();
      final String sizeMb = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);
      final String tempId = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      _setProgress(tempId, 0.0);
      try {
        final presign = await getPresigned(
          caseId,
          fileExtension: ext,
          fileName: fileName,
          fileSizeMb: sizeMb,
          fileType: 'image',
          originalFileName: fileName,
        );
        final uploadUrl = presign['upload_url'] as String;
        final objectKey = presign['object_key'] as String;
        final fileUuid = presign['file_uuid'] as String;
        final serverMime = presign['mime_type'] as String? ?? mimeType;

        await uploadToS3(
          uploadUrl,
          await file.readAsBytes(),
          serverMime,
          (sent, total) {
            if (total > 0) {
              _setProgress(tempId, sent / total);
            }
          },
        );

        await confirmUpload(
          caseId,
          fileExtension: ext,
          fileName: fileName,
          fileType: 'image',
          fileUuid: fileUuid,
          mimeType: serverMime,
          objectKey: objectKey,
          originalFileName: fileName,
        );
      } catch (e) {
        // swallow error for now, but mark progress row gone
      } finally {
        _removeProgress(tempId);
      }
    }
    await fetch(caseId);
  }

  void _setProgress(String id, double p) {
    final newMap = Map<String, double>.from(state.progress);
    newMap[id] = p;
    emit(state.copyWith(progress: newMap));
  }

  void _removeProgress(String id) {
    final newMap = Map<String, double>.from(state.progress);
    newMap.remove(id);
    emit(state.copyWith(progress: newMap));
  }

  String _inferMime(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}

