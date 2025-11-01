import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/exceptions/auth_exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit(this.loginUseCase) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final user = await loginUseCase(email, password);
      emit(LoginSuccess(user));
    } on LoginException catch (e) {
      emit(LoginError(e.message));
    } on NetworkException catch (e) {
      emit(LoginError(e.message));
    } on ServerException catch (e) {
      emit(LoginError(e.message));
    } on AuthException catch (e) {
      emit(LoginError(e.message));
    } catch (e) {
      emit(LoginError('An unexpected error occurred. Please try again.'));
    }
  }

  void reset() {
    emit(LoginInitial());
  }
}
