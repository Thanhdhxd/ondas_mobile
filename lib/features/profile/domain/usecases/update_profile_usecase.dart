import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';

abstract class UpdateProfileUseCase {
  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params);
}

class UpdateProfileParams {
  final String displayName;

  const UpdateProfileParams({required this.displayName});
}
