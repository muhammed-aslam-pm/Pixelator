import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthChecking());
    try {
      final isAuthenticated = await repository.isAuthenticated();
      if (isAuthenticated) {
        // Try to get cached user or fetch from API
        final cachedUser = await repository.getCachedUser();
        if (cachedUser != null) {
          emit(AuthAuthenticated(cachedUser));
        } else {
          // Fetch current user from API
          final user = await repository.getCurrentUser();
          emit(AuthAuthenticated(user));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      AppLogger.e('Error checking auth status', e);
      emit(AuthUnauthenticated());
    }
  }

  void setAuthenticated(UserEntity user) {
    emit(AuthAuthenticated(user));
  }

  void setUnauthenticated() {
    emit(AuthUnauthenticated());
  }
}

