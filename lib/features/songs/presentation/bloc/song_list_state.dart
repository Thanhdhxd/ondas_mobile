import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

abstract class SongListState extends Equatable {
  const SongListState();

  @override
  List<Object?> get props => [];
}

class SongListInitial extends SongListState {
  const SongListInitial();
}

class SongListLoading extends SongListState {
  const SongListLoading();
}

class SongListLoaded extends SongListState {
  final List<SongSummary> songs;
  final int page;
  final int totalPages;
  final bool hasMore;

  const SongListLoaded({
    required this.songs,
    required this.page,
    required this.totalPages,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [songs, page, totalPages, hasMore];
}

class SongListLoadingMore extends SongListLoaded {
  const SongListLoadingMore({
    required super.songs,
    required super.page,
    required super.totalPages,
    required super.hasMore,
  });
}

class SongListFailure extends SongListState {
  final String message;

  const SongListFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
