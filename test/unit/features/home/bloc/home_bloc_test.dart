import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/home_data.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_state.dart';

class MockGetHomeDataUseCase extends Mock implements GetHomeDataUseCase {}

void main() {
  late HomeBloc bloc;
  late MockGetHomeDataUseCase mockUseCase;

  final tHomeData = HomeData(
    trendingSongs: [
      SongSummary(
        id: 'song-1',
        title: 'Test Song',
        slug: 'test-song',
        durationSeconds: 210,
        audioUrl: 'https://example.com/audio.mp3',
        playCount: 1000,
        active: true,
        artists: const [ArtistRef(id: 'a1', name: 'Test Artist')],
        genres: const [GenreRef(id: 1, name: 'Pop')],
      ),
    ],
    featuredArtists: const [
      ArtistSummary(id: 'artist-1', name: 'Test Artist', slug: 'test-artist'),
    ],
    newReleases: const [
      AlbumSummary(
        id: 'album-1',
        title: 'Test Album',
        slug: 'test-album',
        totalTracks: 10,
        artistIds: ['a1'],
      ),
    ],
  );

  setUp(() {
    mockUseCase = MockGetHomeDataUseCase();
    bloc = HomeBloc(getHomeDataUseCase: mockUseCase);
  });

  tearDown(() => bloc.close());

  group('HomeBloc — HomeLoadRequested', () {
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] when use case succeeds',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => Right(tHomeData));
        return bloc;
      },
      act: (b) => b.add(const HomeLoadRequested()),
      expect: () => [
        const HomeLoading(),
        HomeLoaded(data: tHomeData),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeFailure] when use case returns ServerFailure',
      build: () {
        when(() => mockUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (b) => b.add(const HomeLoadRequested()),
      expect: () => [
        const HomeLoading(),
        const HomeFailure(message: 'Server error'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeFailure] when use case returns NetworkFailure',
      build: () {
        when(() => mockUseCase()).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'No connection')),
        );
        return bloc;
      },
      act: (b) => b.add(const HomeLoadRequested()),
      expect: () => [
        const HomeLoading(),
        const HomeFailure(message: 'No connection'),
      ],
    );
  });

  group('HomeBloc — HomeRefreshRequested', () {
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoaded] (no loading) when refresh succeeds',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => Right(tHomeData));
        return bloc;
      },
      act: (b) => b.add(const HomeRefreshRequested()),
      expect: () => [HomeLoaded(data: tHomeData)],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeFailure] when refresh returns error',
      build: () {
        when(() => mockUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (b) => b.add(const HomeRefreshRequested()),
      expect: () => [const HomeFailure(message: 'Server error')],
    );
  });
}
