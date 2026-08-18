import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}

class AuthFailed extends AuthState {
  final String message;
  AuthFailed(this.message);
}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailed(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(email, password, fullName);
      final user = await _authRepository.login(email, password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailed(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> checkSession() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.checkSession();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(Unauthenticated());
  }
}
