import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ResetPasswordUseCase _resetPasswordUseCase;

  ResetPasswordBloc({required ResetPasswordUseCase resetPasswordUseCase})
      : _resetPasswordUseCase = resetPasswordUseCase,
        super(const ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(const ResetPasswordLoading());
    final result = await _resetPasswordUseCase(
      ResetPasswordParams(
        email: event.email,
        otp: event.otp,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(ResetPasswordFailure(message: failure.message)),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }
}
