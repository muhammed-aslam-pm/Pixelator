// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  userId: (json['user_id'] as num).toInt(),
  userUuid: json['user_uuid'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  orgId: (json['org_id'] as num).toInt(),
  roles:
      (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'user_id': instance.userId,
  'user_uuid': instance.userUuid,
  'email': instance.email,
  'full_name': instance.fullName,
  'org_id': instance.orgId,
  'roles': instance.roles,
  'permissions': instance.permissions,
};
