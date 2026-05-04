import 'package:equatable/equatable.dart';

sealed class FavoriteToggleEvent extends Equatable {
  const FavoriteToggleEvent();

  @override
  List<Object?> get props => [];
}

class FavoriteStatusCheckRequested extends FavoriteToggleEvent {
  final String songId;

  const FavoriteStatusCheckRequested(this.songId);

  @override
  List<Object?> get props => [songId];
}

class FavoriteToggleRequested extends FavoriteToggleEvent {
  final String songId;
  final bool currentStatus;

  const FavoriteToggleRequested({
    required this.songId,
    required this.currentStatus,
  });

  @override
  List<Object?> get props => [songId, currentStatus];
}
