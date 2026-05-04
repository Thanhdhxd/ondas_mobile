import 'package:equatable/equatable.dart';

sealed class FavoriteToggleState extends Equatable {
  const FavoriteToggleState();

  @override
  List<Object?> get props => [];
}

class FavoriteToggleInitial extends FavoriteToggleState {
  const FavoriteToggleInitial();
}

class FavoriteToggleLoading extends FavoriteToggleState {
  const FavoriteToggleLoading();
}

class FavoriteToggleLoaded extends FavoriteToggleState {
  final bool isFavorited;

  const FavoriteToggleLoaded({required this.isFavorited});

  @override
  List<Object?> get props => [isFavorited];
}

class FavoriteToggleError extends FavoriteToggleState {
  final String message;
  final bool previousStatus;

  const FavoriteToggleError({required this.message, required this.previousStatus});

  @override
  List<Object?> get props => [message, previousStatus];
}
