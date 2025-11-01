import 'package:pixelator/domain/entities/case_entity.dart';

import '../../domain/entities/cases_response_entity.dart';
import '../../domain/repositories/case_repository.dart';
import '../data_sources/case_remote_data_source.dart';

class CaseRepositoryImpl implements CaseRepository {
  final CaseRemoteDataSource remoteDataSource;

  CaseRepositoryImpl(this.remoteDataSource);

  @override
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
  }) async {
    final response = await remoteDataSource.getCases(
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
    return response.toEntity();
  }

  @override
  Future<CaseEntity> getCaseById(int caseId) async {
    final caseModel = await remoteDataSource.getCaseById(caseId);
    return caseModel.toEntity();
  }
}
