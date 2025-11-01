import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/exceptions/auth_exceptions.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/usecases/get_case_by_id_usecase.dart';

part 'case_detail_state.dart';

class CaseDetailCubit extends Cubit<CaseDetailState> {
  final GetCaseByIdUseCase getCaseByIdUseCase;

  CaseDetailCubit(this.getCaseByIdUseCase) : super(CaseDetailInitial());

  Future<void> getCaseById(int caseId) async {
    emit(CaseDetailLoading());
    try {
      final caseEntity = await getCaseByIdUseCase(caseId);
      emit(CaseDetailLoaded(caseEntity));
    } on AuthException catch (e) {
      emit(CaseDetailError(e.message));
    } on NetworkException catch (e) {
      emit(CaseDetailError(e.message));
    } on ServerException catch (e) {
      emit(CaseDetailError(e.message));
    } catch (e) {
      emit(CaseDetailError('An unexpected error occurred'));
    }
  }
}
