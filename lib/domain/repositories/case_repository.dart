import 'package:pixelator/domain/entities/case_entity.dart';

import '../entities/cases_response_entity.dart';

abstract class CaseRepository {
  Future<CasesResponseEntity> getCases({
    String? caseName,
    String? caseNo,
    String? hospitalName,
    String? patientId,
    String? specialization,
    int? priority,
    String? status,
    int? assignedTo,
    bool? isCompleted,
    bool? isFlagged,
    bool? hasOpinion,
    String? createdFrom,
    String? createdTo,
    String? flaggedFrom,
    String? flaggedTo,
    String? completedFrom,
    String? completedTo,
    String? archivedFrom,
    String? archivedTo,
    String? sort,
    int page = 1,
    int size = 20,
  });
  Future<CaseEntity> getCaseById(int caseId);
}
