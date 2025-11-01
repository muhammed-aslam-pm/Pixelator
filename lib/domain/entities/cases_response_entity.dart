import 'package:equatable/equatable.dart';
import 'case_entity.dart';

class CasesResponseEntity extends Equatable {
  final List<CaseEntity> cases;
  final int total;
  final int page;
  final int size;
  final int pages;

  const CasesResponseEntity({
    required this.cases,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  @override
  List<Object> get props => [cases, total, page, size, pages];
}

