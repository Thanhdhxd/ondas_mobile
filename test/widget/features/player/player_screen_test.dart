import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_state.dart';
import 'package:ondas_mobile/features/player/presentation/screens/player_screen.dart';

class MockPlayerBloc extends MockBloc<PlayerEvent, PlayerState>
    implements PlayerBloc {}

const tSong = Song(
  id: 'song-1',
  title: 'Test Song',
  artistNames: ['Artist A'],
  audioUrl: 'https://example.com/audio.mp3',
  durationSeconds: 180,
);

const tPlayingState = PlayerState(
  currentSong: tSong,
  queue: [tSong],
  currentIndex: 0,
  status: PlayerStatus.playing,
  position: Duration(seconds: 30),
  duration: Duration(seconds: 180),
  volume: 1.0,
);

void main() {
  late MockPlayerBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const PauseRequested());
    registerFallbackValue(const ResumeRequested());
    registerFallbackValue(const SkipNextRequested());
    registerFallbackValue(const SkipPreviousRequested());
    registerFallbackValue(const VolumeChanged(0.5));
    registerFallbackValue(const SeekRequested(Duration.zero));
  });

  setUp(() {
    mockBloc = MockPlayerBloc();
  });

  Widget buildSubject() => MaterialApp(
        home: BlocProvider<PlayerBloc>.value(
          value: mockBloc,
          child: const PlayerScreen(),
        ),
      );

  group('PlayerScreen', () {
    testWidgets('renders idle view when status is idle', (tester) async {
      when(() => mockBloc.state).thenReturn(const PlayerState());

      await tester.pumpWidget(buildSubject());

      expect(find.text('No song playing'), findsOneWidget);
    });

    testWidgets('renders controls when status is playing', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(400, 900));
      when(() => mockBloc.state).thenReturn(tPlayingState);

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('playerScreen_artwork')), findsOneWidget);
      expect(find.byKey(const Key('playerScreen_info')), findsOneWidget);
      expect(find.byKey(const Key('playerScreen_seekbar')), findsOneWidget);
      expect(find.byKey(const Key('playerScreen_controls')), findsOneWidget);
      expect(find.byKey(const Key('playerScreen_volume')), findsOneWidget);
    });

    testWidgets('renders song title and artist', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(400, 900));
      when(() => mockBloc.state).thenReturn(tPlayingState);

      await tester.pumpWidget(buildSubject());

      expect(find.text('Test Song'), findsOneWidget);
      expect(find.text('Artist A'), findsOneWidget);
    });

    testWidgets('shows loading indicator when status is loading', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(400, 900));
      when(() => mockBloc.state).thenReturn(const PlayerState(
        currentSong: tSong,
        queue: [tSong],
        status: PlayerStatus.loading,
      ));

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('tapping pause button dispatches PauseRequested', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(400, 900));
      when(() => mockBloc.state).thenReturn(tPlayingState);

      await tester.pumpWidget(buildSubject());

      final playPauseBtn = find.byKey(const Key('playerControls_playPauseButton'));
      expect(playPauseBtn, findsOneWidget);
      await tester.ensureVisible(playPauseBtn);
      await tester.tap(playPauseBtn);

      verify(() => mockBloc.add(const PauseRequested())).called(1);
    });

    testWidgets('tapping skip next dispatches SkipNextRequested', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(400, 900));
      when(() => mockBloc.state).thenReturn(const PlayerState(
        currentSong: tSong,
        queue: [tSong, tSong],
        currentIndex: 0,
        status: PlayerStatus.playing,
      ));

      await tester.pumpWidget(buildSubject());

      final skipNextBtn = find.byKey(const Key('playerControls_skipNextButton'));
      expect(skipNextBtn, findsOneWidget);
      await tester.ensureVisible(skipNextBtn);
      await tester.tap(skipNextBtn);

      verify(() => mockBloc.add(const SkipNextRequested())).called(1);
    });
  });
}
