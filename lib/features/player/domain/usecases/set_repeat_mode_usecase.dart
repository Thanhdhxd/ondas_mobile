import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';

abstract class SetRepeatModeUseCase {
  Future<void> call(RepeatMode mode);
}
