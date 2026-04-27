import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/profile/domain/entities/play_history_item.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<PlayHistoryItem> items;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const HistoryLoaded({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, currentPage, totalPages, hasMore];
}

class HistoryLoadingMore extends HistoryState {
  final List<PlayHistoryItem> items;
  final int currentPage;
  final int totalPages;

  const HistoryLoadingMore({
    required this.items,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [items, currentPage, totalPages];
}

class HistoryFailure extends HistoryState {
  final String message;

  const HistoryFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class HistoryClearSuccess extends HistoryState {
  const HistoryClearSuccess();
}
