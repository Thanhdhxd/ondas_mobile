import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/set_repeat_mode_usecase.dart';

class SetRepeatModeUseCaseImpl implements SetRepeatModeUseCase {
  final AudioPlayerService _service;

  const SetRepeatModeUseCaseImpl(this._service);

  @override
  Future<void> call(RepeatMode mode) => _service.setRepeatMode(mode);
}
