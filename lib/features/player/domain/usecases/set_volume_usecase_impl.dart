import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/set_volume_usecase.dart';

class SetVolumeUseCaseImpl implements SetVolumeUseCase {
  final AudioPlayerService _service;

  const SetVolumeUseCaseImpl(this._service);

  @override
  Future<void> call(double volume) => _service.setVolume(volume);
}
