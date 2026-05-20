import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchSubmitted extends SearchEvent {
  final String query;

  const SearchSubmitted(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchLoadMoreRequested extends SearchEvent {
  const SearchLoadMoreRequested();
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}

class TagSearchRequested extends SearchEvent {
  final List<int> tagIds;
  final String queryLabel;

  const TagSearchRequested({
    required this.tagIds,
    required this.queryLabel,
  });

  @override
  List<Object?> get props => [tagIds, queryLabel];
}

class SuggestionsRequested extends SearchEvent {
  const SuggestionsRequested();
}

class SearchHistoryCleared extends SearchEvent {
  const SearchHistoryCleared();
}

