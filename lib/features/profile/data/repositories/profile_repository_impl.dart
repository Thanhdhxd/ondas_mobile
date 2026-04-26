import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _datasource;

  const ProfileRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final result = await _datasource.getProfile();
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String displayName,
  }) async {
    try {
      final result = await _datasource.updateProfile(displayName: displayName);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> uploadAvatar({required String filePath}) async {
    try {
      final result = await _datasource.uploadAvatar(filePath: filePath);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _datasource.changePassword(
        currentPassword: currentPassword,
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
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedFailure();
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkFailure(message: 'Không thể kết nối máy chủ. Vui lòng kiểm tra kết nối mạng.');
    }
    final message = e.response?.data?['message'] as String? ??
        e.message ??
        'Đã xảy ra lỗi không xác định.';
    return ServerFailure(message: message, statusCode: statusCode);
  }
}
