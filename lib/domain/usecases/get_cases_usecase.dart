import '../entities/cases_response_entity.dart';
import '../repositories/case_repository.dart';

class GetCasesUseCase {
  final CaseRepository repository;

  GetCasesUseCase(this.repository);

  Future<CasesResponseEntity> call({
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
  }) {
    return repository.getCases(
      caseName: caseName,
      caseNo: caseNo,
      hospitalName: hospitalName,
      patientId: patientId,
      specialization: specialization,
      priority: priority,
      status: status,
      assignedTo: assignedTo,
      isCompleted: isCompleted,
      isFlagged: isFlagged,
      hasOpinion: hasOpinion,
      createdFrom: createdFrom,
      createdTo: createdTo,
      flaggedFrom: flaggedFrom,
      flaggedTo: flaggedTo,
      completedFrom: completedFrom,
      completedTo: completedTo,
      archivedFrom: archivedFrom,
      archivedTo: archivedTo,
      sort: sort,
      page: page,
      size: size,
    );
  }
}

