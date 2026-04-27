import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/seek_usecase.dart';

class SeekUseCaseImpl implements SeekUseCase {
  final AudioPlayerService _service;

  const SeekUseCaseImpl(this._service);

  @override
  Future<void> call(Duration position) => _service.seek(position);
}
