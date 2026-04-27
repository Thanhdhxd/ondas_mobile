import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/resume_usecase.dart';

class ResumeUseCaseImpl implements ResumeUseCase {
  final AudioPlayerService _service;

  const ResumeUseCaseImpl(this._service);

  @override
  Future<void> call() => _service.resume();
}
