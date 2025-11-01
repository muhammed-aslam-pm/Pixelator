part of 'case_detail_cubit.dart';

abstract class CaseDetailState extends Equatable {
  const CaseDetailState();

  @override
  List<Object?> get props => [];
}

class CaseDetailInitial extends CaseDetailState {
  const CaseDetailInitial();
}

class CaseDetailLoading extends CaseDetailState {
  const CaseDetailLoading();
}

class CaseDetailLoaded extends CaseDetailState {
  final CaseEntity caseEntity;

  const CaseDetailLoaded(this.caseEntity);

  @override
  List<Object?> get props => [caseEntity];
}

class CaseDetailError extends CaseDetailState {
  final String message;

  const CaseDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
