import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_next_usecase.dart';

class SkipNextUseCaseImpl implements SkipNextUseCase {
  final AudioPlayerService _service;

  const SkipNextUseCaseImpl(this._service);

  @override
  Future<void> call() => _service.skipNext();
}
