import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/exceptions/auth_exceptions.dart';
import '../../domain/entities/cases_response_entity.dart';
import '../../domain/usecases/get_cases_usecase.dart';

part 'cases_state.dart';

class CasesCubit extends Cubit<CasesState> {
  final GetCasesUseCase getCasesUseCase;

  CasesCubit(this.getCasesUseCase) : super(CasesInitial());

  Future<void> getCases({
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
    String? sort,
    int page = 1,
    int size = 20,
  }) async {
    emit(CasesLoading());
    try {
      final response = await getCasesUseCase(
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
        sort: sort ?? '-created_at',
        page: page,
        size: size,
      );
      emit(CasesLoaded(response));
    } on NetworkException catch (e) {
      emit(CasesError(e.message));
    } on ServerException catch (e) {
      emit(CasesError(e.message));
    } on AuthException catch (e) {
      emit(CasesError(e.message));
    } catch (e) {
      emit(CasesError('An unexpected error occurred. Please try again.'));
    }
  }

  void reset() {
    emit(CasesInitial());
  }
}

