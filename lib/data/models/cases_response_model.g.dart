// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cases_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CasesResponseModel _$CasesResponseModelFromJson(Map<String, dynamic> json) =>
    CasesResponseModel(
      cases: CasesResponseModel._casesFromJson(json['cases'] as List),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      pages: (json['pages'] as num).toInt(),
    );

Map<String, dynamic> _$CasesResponseModelToJson(CasesResponseModel instance) =>
    <String, dynamic>{
      'cases': CasesResponseModel._casesToJson(instance.cases),
      'total': instance.total,
      'page': instance.page,
      'size': instance.size,
      'pages': instance.pages,
    };
