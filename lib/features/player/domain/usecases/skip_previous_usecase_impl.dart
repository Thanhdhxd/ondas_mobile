import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_previous_usecase.dart';

class SkipPreviousUseCaseImpl implements SkipPreviousUseCase {
  final AudioPlayerService _service;

  const SkipPreviousUseCaseImpl(this._service);

  @override
  Future<void> call() => _service.skipPrevious();
}
