import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/play_song_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/pause_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/resume_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/seek_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_next_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_previous_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/set_volume_usecase_impl.dart';

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

const tSong = Song(
  id: 'song-1',
  title: 'Test Song',
  artistNames: ['Artist A'],
  audioUrl: 'https://example.com/audio.mp3',
  durationSeconds: 180,
);

void main() {
  late MockAudioPlayerService mockService;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    mockService = MockAudioPlayerService();
  });

  // ── PlaySongUseCase ───────────────────────────────────────────────────────

  group('PlaySongUseCase', () {
    late PlaySongUseCaseImpl useCase;

    setUp(() => useCase = PlaySongUseCaseImpl(mockService));

    test('calls service.playSong with correct args', () async {
      when(() => mockService.playSong(songs: any(named: 'songs'), index: any(named: 'index')))
          .thenAnswer((_) async {});

      await useCase(songs: [tSong], index: 0);

      verify(() => mockService.playSong(songs: [tSong], index: 0)).called(1);
    });
  });

  // ── PauseUseCase ─────────────────────────────────────────────────────────

  group('PauseUseCase', () {
    late PauseUseCaseImpl useCase;

    setUp(() => useCase = PauseUseCaseImpl(mockService));

    test('calls service.pause', () async {
      when(() => mockService.pause()).thenAnswer((_) async {});

      await useCase();

      verify(() => mockService.pause()).called(1);
    });
  });

  // ── ResumeUseCase ─────────────────────────────────────────────────────────

  group('ResumeUseCase', () {
    late ResumeUseCaseImpl useCase;

    setUp(() => useCase = ResumeUseCaseImpl(mockService));

    test('calls service.resume', () async {
      when(() => mockService.resume()).thenAnswer((_) async {});

      await useCase();

      verify(() => mockService.resume()).called(1);
    });
  });

  // ── SeekUseCase ───────────────────────────────────────────────────────────

  group('SeekUseCase', () {
    late SeekUseCaseImpl useCase;

    setUp(() => useCase = SeekUseCaseImpl(mockService));

    test('calls service.seek with position', () async {
      const position = Duration(seconds: 45);
      when(() => mockService.seek(any())).thenAnswer((_) async {});

      await useCase(position);

      verify(() => mockService.seek(position)).called(1);
    });
  });

  // ── SkipNextUseCase ───────────────────────────────────────────────────────

  group('SkipNextUseCase', () {
    late SkipNextUseCaseImpl useCase;

    setUp(() => useCase = SkipNextUseCaseImpl(mockService));

    test('calls service.skipNext', () async {
      when(() => mockService.skipNext()).thenAnswer((_) async {});

      await useCase();

      verify(() => mockService.skipNext()).called(1);
    });
  });

  // ── SkipPreviousUseCase ───────────────────────────────────────────────────

  group('SkipPreviousUseCase', () {
    late SkipPreviousUseCaseImpl useCase;

    setUp(() => useCase = SkipPreviousUseCaseImpl(mockService));

    test('calls service.skipPrevious', () async {
      when(() => mockService.skipPrevious()).thenAnswer((_) async {});

      await useCase();

      verify(() => mockService.skipPrevious()).called(1);
    });
  });

  // ── SetVolumeUseCase ──────────────────────────────────────────────────────

  group('SetVolumeUseCase', () {
    late SetVolumeUseCaseImpl useCase;

    setUp(() => useCase = SetVolumeUseCaseImpl(mockService));

    test('calls service.setVolume with correct value', () async {
      when(() => mockService.setVolume(any())).thenAnswer((_) async {});

      await useCase(0.75);

      verify(() => mockService.setVolume(0.75)).called(1);
    });
  });
}
