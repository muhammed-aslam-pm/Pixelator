// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaseModel _$CaseModelFromJson(Map<String, dynamic> json) => CaseModel(
  caseName: json['case_name'] as String,
  caseNo: json['case_no'] as String,
  caseDescription: json['case_description'] as String,
  hospitalName: json['hospital_name'] as String,
  patientId: json['patient_id'] as String,
  specialization: json['specialization'] as String,
  site: json['site'] as String,
  priority: (json['priority'] as num).toInt(),
  assignedTo: (json['assigned_to'] as num).toInt(),
  caseId: (json['case_id'] as num).toInt(),
  caseUuid: json['case_uuid'] as String,
  userId: (json['user_id'] as num).toInt(),
  orgId: (json['org_id'] as num).toInt(),
  slidesCount: (json['slides_count'] as num).toInt(),
  mediaFilesCount: (json['media_files_count'] as num).toInt(),
  totalFileSizeMb: json['total_file_size_mb'] as String,
  status: json['status'] as String,
  isCompleted: json['is_completed'] as bool,
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  completedBy: (json['completed_by'] as num?)?.toInt(),
  isFlagged: json['is_flagged'] as bool,
  flagReason: json['flag_reason'] as String?,
  flaggedAt: json['flagged_at'] == null
      ? null
      : DateTime.parse(json['flagged_at'] as String),
  flaggedBy: (json['flagged_by'] as num?)?.toInt(),
  hasOpinion: json['has_opinion'] as bool,
  opinion: json['opinion'] as String?,
  opinionAddedAt: json['opinion_added_at'] == null
      ? null
      : DateTime.parse(json['opinion_added_at'] as String),
  opinionAddedBy: (json['opinion_added_by'] as num?)?.toInt(),
  archivalStatus: json['archival_status'] as bool,
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
  archivedBy: (json['archived_by'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  createdBy: (json['created_by'] as num).toInt(),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  updatedBy: (json['updated_by'] as num).toInt(),
);

Map<String, dynamic> _$CaseModelToJson(CaseModel instance) => <String, dynamic>{
  'case_name': instance.caseName,
  'case_no': instance.caseNo,
  'case_description': instance.caseDescription,
  'hospital_name': instance.hospitalName,
  'patient_id': instance.patientId,
  'specialization': instance.specialization,
  'site': instance.site,
  'priority': instance.priority,
  'assigned_to': instance.assignedTo,
  'case_id': instance.caseId,
  'case_uuid': instance.caseUuid,
  'user_id': instance.userId,
  'org_id': instance.orgId,
  'slides_count': instance.slidesCount,
  'media_files_count': instance.mediaFilesCount,
  'total_file_size_mb': instance.totalFileSizeMb,
  'status': instance.status,
  'is_completed': instance.isCompleted,
  'completed_at': instance.completedAt?.toIso8601String(),
  'completed_by': instance.completedBy,
  'is_flagged': instance.isFlagged,
  'flag_reason': instance.flagReason,
  'flagged_at': instance.flaggedAt?.toIso8601String(),
  'flagged_by': instance.flaggedBy,
  'has_opinion': instance.hasOpinion,
  'opinion': instance.opinion,
  'opinion_added_at': instance.opinionAddedAt?.toIso8601String(),
  'opinion_added_by': instance.opinionAddedBy,
  'archival_status': instance.archivalStatus,
  'archived_at': instance.archivedAt?.toIso8601String(),
  'archived_by': instance.archivedBy,
  'created_at': instance.createdAt.toIso8601String(),
  'created_by': instance.createdBy,
  'updated_at': instance.updatedAt.toIso8601String(),
  'updated_by': instance.updatedBy,
};
