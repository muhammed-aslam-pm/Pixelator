import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  @JsonKey(name: 'user_id')
  final int userId;
  
  @JsonKey(name: 'user_uuid')
  final String userUuid;
  
  final String email;
  
  @JsonKey(name: 'full_name')
  final String fullName;
  
  @JsonKey(name: 'org_id')
  final int orgId;
  
  @JsonKey(defaultValue: <String>[])
  final List<String> roles;
  
  @JsonKey(defaultValue: <String>[])
  final List<String> permissions;

  const UserModel({
    required this.userId,
    required this.userUuid,
    required this.email,
    required this.fullName,
    required this.orgId,
    this.roles = const <String>[],
    this.permissions = const <String>[],
  }) : super(
          userId: userId,
          userUuid: userUuid,
          email: email,
          fullName: fullName,
          orgId: orgId,
          roles: roles,
          permissions: permissions,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$UserModelFromJson(json);
    } catch (e) {
      // Handle null or missing fields with defaults
      return UserModel(
        userId: json['user_id'] as int? ?? 0,
        userUuid: json['user_uuid'] as String? ?? '',
        email: json['email'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        orgId: json['org_id'] as int? ?? 0,
        roles: (json['roles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>[],
        permissions: (json['permissions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>[],
      );
    }
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      userUuid: userUuid,
      email: email,
      fullName: fullName,
      orgId: orgId,
      roles: roles,
      permissions: permissions,
    );
  }
}
