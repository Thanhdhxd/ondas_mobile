import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/profile/domain/entities/play_history_item.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/clear_play_history_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/delete_play_history_item_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_play_history_usecase.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_bloc.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_event.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_state.dart';

class MockGetPlayHistoryUseCase extends Mock implements GetPlayHistoryUseCase {}

class MockDeletePlayHistoryItemUseCase extends Mock implements DeletePlayHistoryItemUseCase {}

class MockClearPlayHistoryUseCase extends Mock implements ClearPlayHistoryUseCase {}

class FakeGetPlayHistoryParams extends Fake implements GetPlayHistoryParams {}

class FakeDeletePlayHistoryItemParams extends Fake implements DeletePlayHistoryItemParams {}

void main() {
  late HistoryBloc bloc;
  late MockGetPlayHistoryUseCase mockGetPlayHistory;
  late MockDeletePlayHistoryItemUseCase mockDeleteItem;
  late MockClearPlayHistoryUseCase mockClearHistory;

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
    source: 'search',
  );

  final tPageFirstEmpty = PageResult<PlayHistoryItem>(
    items: const [],
    page: 0,
    size: 20,
    totalElements: 0,
    totalPages: 0,
  );

  final tPageFirst = PageResult<PlayHistoryItem>(
    items: [tItem1, tItem2],
    page: 0,
    size: 20,
    totalElements: 2,
    totalPages: 1,
  );

  final tPageSecond = PageResult<PlayHistoryItem>(
    items: [tItem2],
    page: 1,
    size: 20,
    totalElements: 2,
    totalPages: 2,
  );

  setUpAll(() {
    registerFallbackValue(FakeGetPlayHistoryParams());
    registerFallbackValue(FakeDeletePlayHistoryItemParams());
  });

  setUp(() {
    mockGetPlayHistory = MockGetPlayHistoryUseCase();
    mockDeleteItem = MockDeletePlayHistoryItemUseCase();
    mockClearHistory = MockClearPlayHistoryUseCase();
    bloc = HistoryBloc(
      getPlayHistoryUseCase: mockGetPlayHistory,
      deletePlayHistoryItemUseCase: mockDeleteItem,
      clearPlayHistoryUseCase: mockClearHistory,
    );
  });

  tearDown(() => bloc.close());

  group('HistoryBloc — HistoryLoadRequested', () {
    blocTest<HistoryBloc, HistoryState>(
      'emits [HistoryLoading, HistoryLoaded] when items returned',
      build: () {
        when(() => mockGetPlayHistory(any())).thenAnswer((_) async => Right(tPageFirst));
        return bloc;
      },
      act: (b) => b.add(const HistoryLoadRequested()),
      expect: () => [
        const HistoryLoading(),
        HistoryLoaded(
          items: [tItem1, tItem2],
          currentPage: 0,
          totalPages: 1,
          hasMore: false,
        ),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits [HistoryLoading, HistoryLoaded(empty)] when no items',
      build: () {
        when(() => mockGetPlayHistory(any())).thenAnswer((_) async => Right(tPageFirstEmpty));
        return bloc;
      },
      act: (b) => b.add(const HistoryLoadRequested()),
      expect: () => [
        const HistoryLoading(),
        const HistoryLoaded(items: [], currentPage: 0, totalPages: 0, hasMore: false),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits [HistoryLoading, HistoryFailure] when usecase returns failure',
      build: () {
        when(() => mockGetPlayHistory(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (b) => b.add(const HistoryLoadRequested()),
      expect: () => [
        const HistoryLoading(),
        const HistoryFailure(message: 'Server error'),
      ],
    );
  });

  group('HistoryBloc — HistoryLoadMore', () {
    blocTest<HistoryBloc, HistoryState>(
      'emits [HistoryLoadingMore, HistoryLoaded] with merged items when hasMore=true',
      build: () {
        when(() => mockGetPlayHistory(any())).thenAnswer((_) async => Right(tPageSecond));
        return bloc;
      },
      seed: () => HistoryLoaded(
        items: [tItem1],
        currentPage: 0,
        totalPages: 2,
        hasMore: true,
      ),
      act: (b) => b.add(const HistoryLoadMore()),
      expect: () => [
        HistoryLoadingMore(items: [tItem1], currentPage: 0, totalPages: 2),
        HistoryLoaded(
          items: [tItem1, tItem2],
          currentPage: 1,
          totalPages: 2,
          hasMore: false,
        ),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'does nothing when hasMore=false',
      build: () => bloc,
      seed: () => HistoryLoaded(
        items: [tItem1],
        currentPage: 0,
        totalPages: 1,
        hasMore: false,
      ),
      act: (b) => b.add(const HistoryLoadMore()),
      expect: () => <HistoryState>[],
    );
  });

  group('HistoryBloc — HistoryItemDeleteRequested', () {
    blocTest<HistoryBloc, HistoryState>(
      'emits HistoryLoaded without deleted item on success',
      build: () {
        when(() => mockDeleteItem(any())).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => HistoryLoaded(
        items: [tItem1, tItem2],
        currentPage: 0,
        totalPages: 1,
        hasMore: false,
      ),
      act: (b) => b.add(const HistoryItemDeleteRequested(id: 1)),
      expect: () => [
        HistoryLoaded(
          items: [tItem2],
          currentPage: 0,
          totalPages: 1,
          hasMore: false,
        ),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits HistoryFailure when delete fails',
      build: () {
        when(() => mockDeleteItem(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Delete failed')),
        );
        return bloc;
      },
      seed: () => HistoryLoaded(
        items: [tItem1],
        currentPage: 0,
        totalPages: 1,
        hasMore: false,
      ),
      act: (b) => b.add(const HistoryItemDeleteRequested(id: 1)),
      expect: () => [const HistoryFailure(message: 'Delete failed')],
    );
  });

  group('HistoryBloc — HistoryClearRequested', () {
    blocTest<HistoryBloc, HistoryState>(
      'emits HistoryClearSuccess on success',
      build: () {
        when(() => mockClearHistory()).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) => b.add(const HistoryClearRequested()),
      expect: () => [const HistoryClearSuccess()],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits HistoryFailure when clear fails',
      build: () {
        when(() => mockClearHistory()).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'No connection')),
        );
        return bloc;
      },
      act: (b) => b.add(const HistoryClearRequested()),
      expect: () => [const HistoryFailure(message: 'No connection')],
    );
  });
}
