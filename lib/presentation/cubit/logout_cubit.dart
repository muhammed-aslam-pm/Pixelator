import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final AuthRepository repository;

  LogoutCubit(this.repository) : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());
    try {
      await repository.logout();
      emit(LogoutSuccess());
    } on NetworkException catch (e) {
      emit(LogoutError(e.message));
    } on ServerException catch (e) {
      emit(LogoutError(e.message));
    } on AuthException catch (e) {
      emit(LogoutError(e.message));
    } catch (e) {
      emit(LogoutError('An unexpected error occurred. Please try again.'));
    }
  }
}

