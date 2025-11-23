import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/case_entity.dart';

part 'case_model.g.dart';

@JsonSerializable()
class CaseModel extends CaseEntity {
  @JsonKey(name: 'case_name')
  final String caseName;

  @JsonKey(name: 'case_no')
  final String caseNo;

  @JsonKey(name: 'case_description')
  final String caseDescription;

  @JsonKey(name: 'hospital_name')
  final String hospitalName;

  @JsonKey(name: 'patient_id')
  final String patientId;

  final String specialization;
  final String site;
  final int priority;

  @JsonKey(name: 'assigned_to')
  final int assignedTo;

  @JsonKey(name: 'case_id')
  final int caseId;

  @JsonKey(name: 'case_uuid')
  final String caseUuid;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'org_id')
  final int orgId;

  @JsonKey(name: 'slides_count')
  final int slidesCount;

  @JsonKey(name: 'media_files_count')
  final int mediaFilesCount;

  @JsonKey(name: 'total_file_size_mb')
  final String totalFileSizeMb;

  final String status;

  @JsonKey(name: 'is_completed')
  final bool isCompleted;

  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  @JsonKey(name: 'completed_by')
  final int? completedBy;

  @JsonKey(name: 'is_flagged')
  final bool isFlagged;

  @JsonKey(name: 'flag_reason')
  final String? flagReason;

  @JsonKey(name: 'flagged_at')
  final DateTime? flaggedAt;

  @JsonKey(name: 'flagged_by')
  final int? flaggedBy;

  @JsonKey(name: 'has_opinion')
  final bool hasOpinion;

  final String? opinion;

  @JsonKey(name: 'opinion_added_at')
  final DateTime? opinionAddedAt;

  @JsonKey(name: 'opinion_added_by')
  final int? opinionAddedBy;

  @JsonKey(name: 'archival_status')
  final bool archivalStatus;

  @JsonKey(name: 'archived_at')
  final DateTime? archivedAt;

  @JsonKey(name: 'archived_by')
  final int? archivedBy;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'created_by')
  final int createdBy;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'updated_by')
  final int? updatedBy;

  const CaseModel({
    required this.caseName,
    required this.caseNo,
    required this.caseDescription,
    required this.hospitalName,
    required this.patientId,
    required this.specialization,
    required this.site,
    required this.priority,
    required this.assignedTo,
    required this.caseId,
    required this.caseUuid,
    required this.userId,
    required this.orgId,
    required this.slidesCount,
    required this.mediaFilesCount,
    required this.totalFileSizeMb,
    required this.status,
    required this.isCompleted,
    this.completedAt,
    this.completedBy,
    required this.isFlagged,
    this.flagReason,
    this.flaggedAt,
    this.flaggedBy,
    required this.hasOpinion,
    this.opinion,
    this.opinionAddedAt,
    this.opinionAddedBy,
    required this.archivalStatus,
    this.archivedAt,
    this.archivedBy,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    this.updatedBy,
  }) : super(
         caseName: caseName,
         caseNo: caseNo,
         caseDescription: caseDescription,
         hospitalName: hospitalName,
         patientId: patientId,
         specialization: specialization,
         site: site,
         priority: priority,
         assignedTo: assignedTo,
         caseId: caseId,
         caseUuid: caseUuid,
         userId: userId,
         orgId: orgId,
         slidesCount: slidesCount,
         mediaFilesCount: mediaFilesCount,
         totalFileSizeMb: totalFileSizeMb,
         status: status,
         isCompleted: isCompleted,
         completedAt: completedAt,
         completedBy: completedBy,
         isFlagged: isFlagged,
         flagReason: flagReason,
         flaggedAt: flaggedAt,
         flaggedBy: flaggedBy,
         hasOpinion: hasOpinion,
         opinion: opinion,
         opinionAddedAt: opinionAddedAt,
         opinionAddedBy: opinionAddedBy,
         archivalStatus: archivalStatus,
         archivedAt: archivedAt,
         archivedBy: archivedBy,
         createdAt: createdAt,
         createdBy: createdBy,
         updatedAt: updatedAt,
         updatedBy: updatedBy,
       );

  factory CaseModel.fromJson(Map<String, dynamic> json) =>
      _$CaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CaseModelToJson(this);

  CaseEntity toEntity() {
    return CaseEntity(
      caseName: caseName,
      caseNo: caseNo,
      caseDescription: caseDescription,
      hospitalName: hospitalName,
      patientId: patientId,
      specialization: specialization,
      site: site,
      priority: priority,
      assignedTo: assignedTo,
      caseId: caseId,
      caseUuid: caseUuid,
      userId: userId,
      orgId: orgId,
      slidesCount: slidesCount,
      mediaFilesCount: mediaFilesCount,
      totalFileSizeMb: totalFileSizeMb,
      status: status,
      isCompleted: isCompleted,
      completedAt: completedAt,
      completedBy: completedBy,
      isFlagged: isFlagged,
      flagReason: flagReason,
      flaggedAt: flaggedAt,
      flaggedBy: flaggedBy,
      hasOpinion: hasOpinion,
      opinion: opinion,
      opinionAddedAt: opinionAddedAt,
      opinionAddedBy: opinionAddedBy,
      archivalStatus: archivalStatus,
      archivedAt: archivedAt,
      archivedBy: archivedBy,
      createdAt: createdAt,
      createdBy: createdBy,
      updatedAt: updatedAt,
      updatedBy: updatedBy,
    );
  }
}
