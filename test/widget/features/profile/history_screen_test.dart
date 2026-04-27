import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/profile/domain/entities/play_history_item.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_bloc.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_event.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_state.dart';
import 'package:ondas_mobile/features/profile/presentation/screens/history_screen.dart';

class MockHistoryBloc extends MockBloc<HistoryEvent, HistoryState>
    implements HistoryBloc {}

class _FakeHistoryEvent extends Fake implements HistoryEvent {}

void main() {
  late MockHistoryBloc mockBloc;

  final tSong = PlayHistorySong(
    id: 'song-uuid',
    title: 'Test Song',
    durationSeconds: 210,
    audioUrl: 'http://host/audio.mp3',
  );

  final tItem1 = PlayHistoryItem(
    id: 1,
    song: tSong,
    playedAt: DateTime(2026, 4, 27, 10),
    source: 'home',
  );

  final tItem2 = PlayHistoryItem(
    id: 2,
    song: tSong,
    playedAt: DateTime(2026, 4, 26, 8),
  );

  setUpAll(() {
    registerFallbackValue(_FakeHistoryEvent());
  });

  setUp(() {
    mockBloc = MockHistoryBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<HistoryBloc>.value(
        value: mockBloc,
        child: const HistoryScreen(),
      ),
    );
  }

  group('HistoryScreen', () {
    testWidgets('shows loading indicator when state is HistoryLoading',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const HistoryLoading());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty view when HistoryLoaded with empty items',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        const HistoryLoaded(
          items: [],
          currentPage: 0,
          totalPages: 0,
          hasMore: false,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('No listening history yet'), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('shows list of items when HistoryLoaded with items',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        HistoryLoaded(
          items: [tItem1, tItem2],
          currentPage: 0,
          totalPages: 1,
          hasMore: false,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byKey(const Key('historyScreen_list')), findsOneWidget);
      expect(find.byKey(const Key('historyItem_1')), findsOneWidget);
      expect(find.byKey(const Key('historyItem_2')), findsOneWidget);
      expect(find.text('Test Song'), findsNWidgets(2));
    });

    testWidgets('clear button visible when items exist', (tester) async {
      when(() => mockBloc.state).thenReturn(
        HistoryLoaded(
          items: [tItem1],
          currentPage: 0,
          totalPages: 1,
          hasMore: false,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byKey(const Key('historyScreen_clearButton')), findsOneWidget);
    });

    testWidgets('clear button not visible when list is empty', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const HistoryLoaded(
          items: [],
          currentPage: 0,
          totalPages: 0,
          hasMore: false,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byKey(const Key('historyScreen_clearButton')), findsNothing);
    });

    testWidgets('shows error view when state is HistoryFailure', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const HistoryFailure(message: 'Network error'),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Network error'), findsOneWidget);
      expect(find.byKey(const Key('historyScreen_retryButton')), findsOneWidget);
    });

    testWidgets('tapping retry adds HistoryLoadRequested event', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const HistoryFailure(message: 'Network error'),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      clearInteractions(mockBloc);

      await tester.tap(find.byKey(const Key('historyScreen_retryButton')));
      await tester.pump();

      verify(() => mockBloc.add(const HistoryLoadRequested())).called(1);
    });

    testWidgets('tapping delete button adds HistoryItemDeleteRequested',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        HistoryLoaded(
          items: [tItem1],
          currentPage: 0,
          totalPages: 1,
          hasMore: false,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.ensureVisible(
          find.byKey(const Key('historyItem_delete_1')));
      await tester.tap(find.byKey(const Key('historyItem_delete_1')));
      await tester.pump();

      verify(
        () => mockBloc.add(const HistoryItemDeleteRequested(id: 1)),
      ).called(1);
    });

    testWidgets('tapping clear shows confirmation dialog', (tester) async {
      when(() => mockBloc.state).thenReturn(
        HistoryLoaded(
          items: [tItem1],
          currentPage: 0,
          totalPages: 1,
          hasMore: false,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byKey(const Key('historyScreen_clearButton')));
      await tester.pumpAndSettle();

      expect(find.text('Clear all history?'), findsOneWidget);
      expect(
          find.byKey(const Key('historyScreen_confirmClearButton')),
          findsOneWidget);
    });

    testWidgets(
        'confirming clear dialog adds HistoryClearRequested event',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        HistoryLoaded(
          items: [tItem1],
          currentPage: 0,
          totalPages: 1,
          hasMore: false,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byKey(const Key('historyScreen_clearButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('historyScreen_confirmClearButton')));
      await tester.pumpAndSettle();

      verify(() => mockBloc.add(const HistoryClearRequested())).called(1);
    });

    testWidgets(
        'HistoryLoadRequested is added on init',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const HistoryLoading());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      verify(() => mockBloc.add(const HistoryLoadRequested())).called(1);
    });
  });
}
