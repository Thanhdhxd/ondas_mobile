import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/pause_usecase.dart';

class PauseUseCaseImpl implements PauseUseCase {
  final AudioPlayerService _service;

  const PauseUseCaseImpl(this._service);

  @override
  Future<void> call() => _service.pause();
}
