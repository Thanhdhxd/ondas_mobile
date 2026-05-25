import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/network/connectivity_service.dart';
import 'package:ondas_mobile/core/network/network_status.dart';

class NetworkStatusCubit extends Cubit<NetworkStatus> {
  final ConnectivityService _connectivityService;
  StreamSubscription<NetworkStatus>? _subscription;

  NetworkStatusCubit({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService,
        super(NetworkStatus.unknown) {
    _initialize();
  }

  Future<void> _initialize() async {
    final status = await _connectivityService.checkStatus();
    emit(status);
    _subscription = _connectivityService.onStatusChanged.listen((nextStatus) {
      if (state != nextStatus) {
        emit(nextStatus);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
