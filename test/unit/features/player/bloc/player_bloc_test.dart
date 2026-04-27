import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/pause_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/play_song_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/resume_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/seek_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/set_volume_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_next_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_previous_usecase.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_state.dart';

class MockPlaySongUseCase extends Mock implements PlaySongUseCase {}

class MockPauseUseCase extends Mock implements PauseUseCase {}

class MockResumeUseCase extends Mock implements ResumeUseCase {}

class MockSeekUseCase extends Mock implements SeekUseCase {}

class MockSkipNextUseCase extends Mock implements SkipNextUseCase {}

class MockSkipPreviousUseCase extends Mock implements SkipPreviousUseCase {}

class MockSetVolumeUseCase extends Mock implements SetVolumeUseCase {}

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

const tSong = Song(
  id: 'song-1',
  title: 'Test Song',
  artistNames: ['Artist A'],
  audioUrl: 'https://example.com/audio.mp3',
  durationSeconds: 180,
);

const tSong2 = Song(
  id: 'song-2',
  title: 'Test Song 2',
  artistNames: ['Artist B'],
  audioUrl: 'https://example.com/audio2.mp3',
  durationSeconds: 200,
);

void main() {
  late MockPlaySongUseCase mockPlaySong;
  late MockPauseUseCase mockPause;
  late MockResumeUseCase mockResume;
  late MockSeekUseCase mockSeek;
  late MockSkipNextUseCase mockSkipNext;
  late MockSkipPreviousUseCase mockSkipPrevious;
  late MockSetVolumeUseCase mockSetVolume;
  late MockAudioPlayerService mockService;

  // Stream controllers to drive service streams
  late StreamController<PlayerStatus> statusController;
  late StreamController<Duration> positionController;
  late StreamController<Duration> durationController;
  late StreamController<double> volumeController;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    mockPlaySong = MockPlaySongUseCase();
    mockPause = MockPauseUseCase();
    mockResume = MockResumeUseCase();
    mockSeek = MockSeekUseCase();
    mockSkipNext = MockSkipNextUseCase();
    mockSkipPrevious = MockSkipPreviousUseCase();
    mockSetVolume = MockSetVolumeUseCase();
    mockService = MockAudioPlayerService();

    statusController = StreamController<PlayerStatus>.broadcast();
    positionController = StreamController<Duration>.broadcast();
    durationController = StreamController<Duration>.broadcast();
    volumeController = StreamController<double>.broadcast();

    when(() => mockService.statusStream).thenAnswer((_) => statusController.stream);
    when(() => mockService.positionStream).thenAnswer((_) => positionController.stream);
    when(() => mockService.durationStream).thenAnswer((_) => durationController.stream);
    when(() => mockService.volumeStream).thenAnswer((_) => volumeController.stream);
    when(() => mockService.dispose()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await statusController.close();
    await positionController.close();
    await durationController.close();
    await volumeController.close();
  });

  PlayerBloc buildBloc() => PlayerBloc(
        playSongUseCase: mockPlaySong,
        pauseUseCase: mockPause,
        resumeUseCase: mockResume,
        seekUseCase: mockSeek,
        skipNextUseCase: mockSkipNext,
        skipPreviousUseCase: mockSkipPrevious,
        setVolumeUseCase: mockSetVolume,
        audioPlayerService: mockService,
      );

  group('PlayerBloc', () {
    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state.status, PlayerStatus.idle);
      expect(bloc.state.currentSong, isNull);
      expect(bloc.state.queue, isEmpty);
      bloc.close();
    });

    blocTest<PlayerBloc, PlayerState>(
      'PlaySongRequested emits loading state with song',
      build: () {
        when(() => mockPlaySong(songs: any(named: 'songs'), index: any(named: 'index')))
            .thenAnswer((_) async {});
        when(() => mockService.currentSong).thenReturn(tSong);
        when(() => mockService.currentIndex).thenReturn(0);
        return buildBloc();
      },
      act: (b) => b.add(const PlaySongRequested(songs: [tSong], index: 0)),
      expect: () => [
        isA<PlayerState>()
            .having((s) => s.status, 'status', PlayerStatus.loading)
            .having((s) => s.currentSong, 'currentSong', tSong)
            .having((s) => s.queue, 'queue', [tSong])
            .having((s) => s.currentIndex, 'index', 0),
      ],
      verify: (_) {
        verify(() => mockPlaySong(songs: [tSong], index: 0)).called(1);
      },
    );

    blocTest<PlayerBloc, PlayerState>(
      'PauseRequested calls pause use case',
      build: () {
        when(() => mockPause()).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (b) => b.add(const PauseRequested()),
      verify: (_) {
        verify(() => mockPause()).called(1);
      },
    );

    blocTest<PlayerBloc, PlayerState>(
      'ResumeRequested calls resume use case',
      build: () {
        when(() => mockResume()).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (b) => b.add(const ResumeRequested()),
      verify: (_) {
        verify(() => mockResume()).called(1);
      },
    );

    blocTest<PlayerBloc, PlayerState>(
      'SeekRequested calls seek use case',
      build: () {
        when(() => mockSeek(any())).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (b) => b.add(const SeekRequested(Duration(seconds: 30))),
      verify: (_) {
        verify(() => mockSeek(const Duration(seconds: 30))).called(1);
      },
    );

    blocTest<PlayerBloc, PlayerState>(
      'SkipNextRequested advances index and calls use case',
      build: () {
        when(() => mockSkipNext()).thenAnswer((_) async {});
        when(() => mockService.currentSong).thenReturn(tSong2);
        when(() => mockService.currentIndex).thenReturn(1);
        return buildBloc()
          ..emit(const PlayerState(
            currentSong: tSong,
            queue: [tSong, tSong2],
            currentIndex: 0,
            status: PlayerStatus.playing,
          ));
      },
      act: (b) => b.add(const SkipNextRequested()),
      expect: () => [
        isA<PlayerState>()
            .having((s) => s.status, 'status', PlayerStatus.loading)
            .having((s) => s.currentIndex, 'index', 1)
            .having((s) => s.currentSong, 'currentSong', tSong2),
      ],
      verify: (_) => verify(() => mockSkipNext()).called(1),
    );

    blocTest<PlayerBloc, PlayerState>(
      'VolumeChanged updates volume state',
      build: () {
        when(() => mockSetVolume(any())).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (b) => b.add(const VolumeChanged(0.5)),
      expect: () => [
        isA<PlayerState>().having((s) => s.volume, 'volume', 0.5),
      ],
      verify: (_) => verify(() => mockSetVolume(0.5)).called(1),
    );

    blocTest<PlayerBloc, PlayerState>(
      'PlayerStatusUpdated emits new status from service stream',
      build: () {
        when(() => mockService.currentSong).thenReturn(tSong);
        when(() => mockService.currentIndex).thenReturn(0);
        return buildBloc();
      },
      act: (b) {
        statusController.add(PlayerStatus.playing);
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<PlayerState>().having((s) => s.status, 'status', PlayerStatus.playing),
      ],
    );

    blocTest<PlayerBloc, PlayerState>(
      'PlayerPositionUpdated emits new position from service stream',
      build: () => buildBloc(),
      act: (b) {
        positionController.add(const Duration(seconds: 10));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<PlayerState>().having((s) => s.position, 'position', const Duration(seconds: 10)),
      ],
    );
  });
}
