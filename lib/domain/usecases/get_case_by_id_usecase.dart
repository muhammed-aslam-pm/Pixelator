import 'package:pixelator/domain/entities/case_entity.dart';
import 'package:pixelator/domain/repositories/case_repository.dart';

class GetCaseByIdUseCase {
  final CaseRepository repository;

  GetCaseByIdUseCase(this.repository);

  Future<CaseEntity> call(int caseId) async {
    return await repository.getCaseById(caseId);
  }
}
