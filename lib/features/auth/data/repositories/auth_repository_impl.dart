import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepository(this._remoteDataSource, {FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<UserModel> login(String email, String password) async {
    final tokenModel = await _remoteDataSource.login(email, password);
    await _secureStorage.write(key: 'auth_token', value: tokenModel.accessToken);
    return await _remoteDataSource.getMe();
  }

  Future<UserModel> register(String email, String password, String fullName) async {
    return await _remoteDataSource.register(email, password, fullName);
  }

  Future<UserModel?> checkSession() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null) return null;
    try {
      return await _remoteDataSource.getMe();
    } catch (_) {
      // Token tidak valid atau kedaluwarsa, hapus token
      await logout();
      return null;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
  }
}
