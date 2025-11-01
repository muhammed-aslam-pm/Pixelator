import 'package:json_annotation/json_annotation.dart';

part 'auth_token_model.g.dart';

@JsonSerializable()
class AuthTokenModel {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  
  @JsonKey(name: 'token_type')
  final String tokenType;
  
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$AuthTokenModelFromJson(json);
    } catch (e) {
      // Handle null or missing fields with defaults
      return AuthTokenModel(
        accessToken: json['access_token'] as String? ?? '',
        refreshToken: json['refresh_token'] as String? ?? '',
        tokenType: json['token_type'] as String? ?? 'bearer',
        expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
      );
    }
  }

  Map<String, dynamic> toJson() => _$AuthTokenModelToJson(this);

  DateTime get expiryDate => DateTime.now().add(Duration(seconds: expiresIn));

  bool get isExpired => DateTime.now().isAfter(expiryDate);
}
