import 'package:json_annotation/json_annotation.dart';

part 'error_response_model.g.dart';

@JsonSerializable()
class ErrorResponseModel {
  final String detail;

  const ErrorResponseModel({
    required this.detail,
  });

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseModelToJson(this);
}

