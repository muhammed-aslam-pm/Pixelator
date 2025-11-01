import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cases_response_entity.dart';
import '../../domain/entities/case_entity.dart';
import 'case_model.dart';

part 'cases_response_model.g.dart';

@JsonSerializable()
class CasesResponseModel extends CasesResponseEntity {
  @JsonKey(fromJson: _casesFromJson, toJson: _casesToJson)
  final List<CaseEntity> cases;
  final int total;
  final int page;
  final int size;
  final int pages;

  const CasesResponseModel({
    required this.cases,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  }) : super(
          cases: cases,
          total: total,
          page: page,
          size: size,
          pages: pages,
        );

  factory CasesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CasesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CasesResponseModelToJson(this);

  CasesResponseEntity toEntity() {
    return CasesResponseEntity(
      cases: cases,
      total: total,
      page: page,
      size: size,
      pages: pages,
    );
  }

  static List<CaseEntity> _casesFromJson(List<dynamic> json) {
    return json.map((e) => CaseModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<Map<String, dynamic>> _casesToJson(List<CaseEntity> cases) {
    return cases.map((e) => (e as CaseModel).toJson()).toList();
  }
}

