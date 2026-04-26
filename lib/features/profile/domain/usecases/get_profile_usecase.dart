import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';

abstract class GetProfileUseCase {
  Future<Either<Failure, UserProfile>> call();
}
