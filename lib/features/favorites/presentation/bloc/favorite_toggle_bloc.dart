import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/add_favorite_usecase.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/check_favorite_status_usecase.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/remove_favorite_usecase.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorite_toggle_event.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorite_toggle_state.dart';

class FavoriteToggleBloc
    extends Bloc<FavoriteToggleEvent, FavoriteToggleState> {
  final CheckFavoriteStatusUseCase _checkFavoriteStatusUseCase;
  final AddFavoriteUseCase _addFavoriteUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;

  FavoriteToggleBloc({
    required CheckFavoriteStatusUseCase checkFavoriteStatusUseCase,
    required AddFavoriteUseCase addFavoriteUseCase,
    required RemoveFavoriteUseCase removeFavoriteUseCase,
  })  : _checkFavoriteStatusUseCase = checkFavoriteStatusUseCase,
        _addFavoriteUseCase = addFavoriteUseCase,
        _removeFavoriteUseCase = removeFavoriteUseCase,
        super(const FavoriteToggleInitial()) {
    on<FavoriteStatusCheckRequested>(_onStatusCheckRequested);
    on<FavoriteToggleRequested>(_onToggleRequested);
  }

  Future<void> _onStatusCheckRequested(
    FavoriteStatusCheckRequested event,
    Emitter<FavoriteToggleState> emit,
  ) async {
    emit(const FavoriteToggleLoading());
    try {
      final isFavorited = await _checkFavoriteStatusUseCase(event.songId);
      emit(FavoriteToggleLoaded(isFavorited: isFavorited));
    } catch (e) {
      emit(FavoriteToggleLoaded(isFavorited: false));
    }
  }

  Future<void> _onToggleRequested(
    FavoriteToggleRequested event,
    Emitter<FavoriteToggleState> emit,
  ) async {
    final optimisticStatus = !event.currentStatus;
    emit(FavoriteToggleLoaded(isFavorited: optimisticStatus));

    try {
      if (event.currentStatus) {
        await _removeFavoriteUseCase(event.songId);
      } else {
        await _addFavoriteUseCase(event.songId);
      }
    } catch (e) {
      emit(FavoriteToggleError(
        message: e.toString(),
        previousStatus: event.currentStatus,
      ));
      emit(FavoriteToggleLoaded(isFavorited: event.currentStatus));
    }
  }
}
