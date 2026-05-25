import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/dio_failure_mapper.dart';
import 'package:ondas_mobile/core/storage/secure_storage.dart';
import 'package:ondas_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ondas_mobile/features/auth/domain/entities/user.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final SecureStorage _secureStorage;

  const AuthRepositoryImpl(this._datasource, this._secureStorage);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _datasource.login(email: email, password: password);
      await _secureStorage.saveAccessToken(result.accessToken);
      await _secureStorage.saveRefreshToken(result.refreshToken);
      return Right(result.user);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _datasource.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      await _secureStorage.saveAccessToken(result.accessToken);
      await _secureStorage.saveRefreshToken(result.refreshToken);
      return Right(result.user);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        await _datasource.logout(refreshToken: refreshToken);
      }
    } on DioException catch (_) {
      // Ignore network errors — always clear tokens locally
    } catch (_) {
      // Ignore errors — always clear tokens locally
    } finally {
      await _secureStorage.clearTokens();
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    try {
      await _datasource.forgotPassword(email: email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _datasource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Failure _mapDioError(DioException e) {
    return DioFailureMapper.map(e);
  }
}
