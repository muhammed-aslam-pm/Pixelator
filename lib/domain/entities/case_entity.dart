import 'package:equatable/equatable.dart';

class CaseEntity extends Equatable {
  final String caseName;
  final String caseNo;
  final String caseDescription;
  final String hospitalName;
  final String patientId;
  final String specialization;
  final String site;
  final int priority;
  final int assignedTo;
  final int caseId;
  final String caseUuid;
  final int userId;
  final int orgId;
  final int slidesCount;
  final int mediaFilesCount;
  final String totalFileSizeMb;
  final String status;
  final bool isCompleted;
  final DateTime? completedAt;
  final int? completedBy;
  final bool isFlagged;
  final String? flagReason;
  final DateTime? flaggedAt;
  final int? flaggedBy;
  final bool hasOpinion;
  final String? opinion;
  final DateTime? opinionAddedAt;
  final int? opinionAddedBy;
  final bool archivalStatus;
  final DateTime? archivedAt;
  final int? archivedBy;
  final DateTime createdAt;
  final int createdBy;
  final DateTime updatedAt;
  final int updatedBy;

  const CaseEntity({
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
    required this.updatedBy,
  });

  String get priorityText {
    switch (priority) {
      case 1:
        return 'Critical';
      case 2:
        return 'High';
      case 3:
        return 'Medium';
      case 4:
        return 'Low';
      case 5:
        return 'Very Low';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [
        caseName,
        caseNo,
        caseDescription,
        hospitalName,
        patientId,
        specialization,
        site,
        priority,
        assignedTo,
        caseId,
        caseUuid,
        userId,
        orgId,
        slidesCount,
        mediaFilesCount,
        totalFileSizeMb,
        status,
        isCompleted,
        completedAt,
        completedBy,
        isFlagged,
        flagReason,
        flaggedAt,
        flaggedBy,
        hasOpinion,
        opinion,
        opinionAddedAt,
        opinionAddedBy,
        archivalStatus,
        archivedAt,
        archivedBy,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
      ];
}

