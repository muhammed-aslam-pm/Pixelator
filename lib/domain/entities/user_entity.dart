import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int userId;
  final String userUuid;
  final String email;
  final String fullName;
  final int orgId;
  final List<String> roles;
  final List<String> permissions;

  const UserEntity({
    required this.userId,
    required this.userUuid,
    required this.email,
    required this.fullName,
    required this.orgId,
    required this.roles,
    required this.permissions,
  });

  @override
  List<Object?> get props => [userId, userUuid, email, fullName, orgId, roles, permissions];
}

