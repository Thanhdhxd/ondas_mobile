import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/clear_play_history_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/delete_play_history_item_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_play_history_usecase.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_event.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetPlayHistoryUseCase _getPlayHistoryUseCase;
  final DeletePlayHistoryItemUseCase _deletePlayHistoryItemUseCase;
  final ClearPlayHistoryUseCase _clearPlayHistoryUseCase;

  static const int _pageSize = 20;

  HistoryBloc({
    required GetPlayHistoryUseCase getPlayHistoryUseCase,
    required DeletePlayHistoryItemUseCase deletePlayHistoryItemUseCase,
    required ClearPlayHistoryUseCase clearPlayHistoryUseCase,
  })  : _getPlayHistoryUseCase = getPlayHistoryUseCase,
        _deletePlayHistoryItemUseCase = deletePlayHistoryItemUseCase,
        _clearPlayHistoryUseCase = clearPlayHistoryUseCase,
        super(const HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistoryLoadMore>(_onLoadMore);
    on<HistoryItemDeleteRequested>(_onItemDeleteRequested);
    on<HistoryClearRequested>(_onClearRequested);
  }

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    final result = await _getPlayHistoryUseCase(
      const GetPlayHistoryParams(page: 0, size: _pageSize),
    );
    result.fold(
      (failure) => emit(HistoryFailure(message: failure.message)),
      (page) => emit(HistoryLoaded(
        items: page.items,
        currentPage: page.page,
        totalPages: page.totalPages,
        hasMore: page.page + 1 < page.totalPages,
      )),
    );
  }

  Future<void> _onLoadMore(
    HistoryLoadMore event,
    Emitter<HistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HistoryLoaded || !currentState.hasMore) return;

    emit(HistoryLoadingMore(
      items: currentState.items,
      currentPage: currentState.currentPage,
      totalPages: currentState.totalPages,
    ));

    final nextPage = currentState.currentPage + 1;
    final result = await _getPlayHistoryUseCase(
      GetPlayHistoryParams(page: nextPage, size: _pageSize),
    );
    result.fold(
      (_) => emit(HistoryLoaded(
        items: currentState.items,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        hasMore: currentState.hasMore,
      )),
      (page) => emit(HistoryLoaded(
        items: [...currentState.items, ...page.items],
        currentPage: page.page,
        totalPages: page.totalPages,
        hasMore: page.page + 1 < page.totalPages,
      )),
    );
  }

  Future<void> _onItemDeleteRequested(
    HistoryItemDeleteRequested event,
    Emitter<HistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HistoryLoaded) return;

    final result = await _deletePlayHistoryItemUseCase(
      DeletePlayHistoryItemParams(id: event.id),
    );
    result.fold(
      (failure) => emit(HistoryFailure(message: failure.message)),
      (_) => emit(HistoryLoaded(
        items: currentState.items.where((item) => item.id != event.id).toList(),
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        hasMore: currentState.hasMore,
      )),
    );
  }

  Future<void> _onClearRequested(
    HistoryClearRequested event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await _clearPlayHistoryUseCase();
    result.fold(
      (failure) => emit(HistoryFailure(message: failure.message)),
      (_) => emit(const HistoryClearSuccess()),
    );
  }
}
