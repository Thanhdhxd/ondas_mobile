import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;

  ForgotPasswordBloc({required ForgotPasswordUseCase forgotPasswordUseCase})
      : _forgotPasswordUseCase = forgotPasswordUseCase,
        super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _forgotPasswordUseCase(
      ForgotPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(ForgotPasswordFailure(message: failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }
}
