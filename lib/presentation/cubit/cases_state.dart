part of 'cases_cubit.dart';

abstract class CasesState extends Equatable {
  const CasesState();

  @override
  List<Object> get props => [];
}

class CasesInitial extends CasesState {}

class CasesLoading extends CasesState {}

class CasesLoaded extends CasesState {
  final CasesResponseEntity response;

  const CasesLoaded(this.response);

  @override
  List<Object> get props => [response];
}

class CasesError extends CasesState {
  final String message;

  const CasesError(this.message);

  @override
  List<Object> get props => [message];
}

