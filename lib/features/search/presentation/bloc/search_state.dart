import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_suggestion.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final String query;
  final List<SongSummary> songs;
  final List<ArtistSummary> artists;
  final List<AlbumSummary> albums;
  final int totalSongs;
  final int totalArtists;
  final int totalAlbums;
  final int page;
  final bool hasMore;

  const SearchLoaded({
    required this.query,
    required this.songs,
    required this.artists,
    required this.albums,
    required this.totalSongs,
    required this.totalArtists,
    required this.totalAlbums,
    required this.page,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [
        query,
        songs,
        artists,
        albums,
        totalSongs,
        totalArtists,
        totalAlbums,
        page,
        hasMore,
      ];
}

class SearchLoadingMore extends SearchLoaded {
  const SearchLoadingMore({
    required super.query,
    required super.songs,
    required super.artists,
    required super.albums,
    required super.totalSongs,
    required super.totalArtists,
    required super.totalAlbums,
    required super.page,
    required super.hasMore,
  });
}

class SearchFailure extends SearchState {
  final String message;

  const SearchFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class SearchSuggestionsLoading extends SearchState {
  const SearchSuggestionsLoading();
}

class SearchSuggestionsLoaded extends SearchState {
  final SearchSuggestion suggestion;

  const SearchSuggestionsLoaded({required this.suggestion});

  @override
  List<Object?> get props => [suggestion];
}
