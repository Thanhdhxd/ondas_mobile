import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_system_playlist_detail_usecase.dart';

part 'system_playlist_detail_event.dart';
part 'system_playlist_detail_state.dart';

class SystemPlaylistDetailBloc
    extends Bloc<SystemPlaylistDetailEvent, SystemPlaylistDetailState> {
  final GetSystemPlaylistDetailUseCase _getDetail;

  SystemPlaylistDetailBloc({
    required GetSystemPlaylistDetailUseCase getSystemPlaylistDetailUseCase,
  })  : _getDetail = getSystemPlaylistDetailUseCase,
        super(const SystemPlaylistDetailInitial()) {
    on<SystemPlaylistDetailStarted>(_onStarted);
  }

  Future<void> _onStarted(
    SystemPlaylistDetailStarted event,
    Emitter<SystemPlaylistDetailState> emit,
  ) async {
    emit(const SystemPlaylistDetailLoading());
    try {
      final detail = await _getDetail(event.playlistId);
      emit(SystemPlaylistDetailLoaded(detail));
    } catch (e) {
      emit(SystemPlaylistDetailError(e.toString()));
    }
  }
}
