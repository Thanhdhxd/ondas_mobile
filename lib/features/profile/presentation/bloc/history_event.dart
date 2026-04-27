import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {
  const HistoryLoadRequested();
}

class HistoryLoadMore extends HistoryEvent {
  const HistoryLoadMore();
}

class HistoryItemDeleteRequested extends HistoryEvent {
  final int id;

  const HistoryItemDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class HistoryClearRequested extends HistoryEvent {
  const HistoryClearRequested();
}
