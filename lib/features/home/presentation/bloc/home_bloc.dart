import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDataUseCase _getHomeDataUseCase;

  HomeBloc({required GetHomeDataUseCase getHomeDataUseCase})
      : _getHomeDataUseCase = getHomeDataUseCase,
        super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final result = await _getHomeDataUseCase();
    result.fold(
      (failure) => emit(HomeFailure(message: failure.message)),
      (data) => emit(HomeLoaded(data: data)),
    );
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    final result = await _getHomeDataUseCase();
    result.fold(
      (failure) => emit(HomeFailure(message: failure.message)),
      (data) => emit(HomeLoaded(data: data)),
    );
  }
}
