import 'package:ondas_mobile/features/auth/data/models/auth_response_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> logout({required String refreshToken});

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}
