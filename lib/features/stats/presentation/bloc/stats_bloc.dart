import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:ondas_mobile/features/stats/presentation/bloc/stats_event.dart';
import 'package:ondas_mobile/features/stats/presentation/bloc/stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final StatsRepository _repository;

  StatsBloc(this._repository) : super(const StatsState()) {
    on<LoadStats>(_onLoadStats);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(state.copyWith(status: StatsStatus.loading, errorMessage: null));

    final listeningTimeResult = await _repository.getListeningTime();
    final topSongsResult = await _repository.getTopSongs(limit: 10);
    final topArtistsResult = await _repository.getTopArtists(limit: 10);

    // Xử lý lỗi nếu có bất kỳ request nào thất bại
    String? error;
    listeningTimeResult.fold((l) => error = l.message, (r) => null);
    if (error == null) topSongsResult.fold((l) => error = l.message, (r) => null);
    if (error == null) topArtistsResult.fold((l) => error = l.message, (r) => null);

    if (error != null) {
      emit(state.copyWith(status: StatsStatus.error, errorMessage: error));
      return;
    }

    emit(state.copyWith(
      status: StatsStatus.loaded,
      listeningTime: listeningTimeResult.getOrElse((_) => throw Exception()),
      topSongs: topSongsResult.getOrElse((_) => throw Exception()),
      topArtists: topArtistsResult.getOrElse((_) => throw Exception()),
    ));
  }
}
