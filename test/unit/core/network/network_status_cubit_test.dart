import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/network/connectivity_service.dart';
import 'package:ondas_mobile/core/network/network_status.dart';
import 'package:ondas_mobile/core/network/network_status_cubit.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockConnectivityService connectivityService;
  late StreamController<NetworkStatus> statusController;

  setUp(() {
    connectivityService = MockConnectivityService();
    statusController = StreamController<NetworkStatus>.broadcast();
    when(() => connectivityService.onStatusChanged)
        .thenAnswer((_) => statusController.stream);
  });

  tearDown(() async {
    await statusController.close();
  });

  blocTest<NetworkStatusCubit, NetworkStatus>(
    'emits initial status and updates on changes',
    build: () {
      when(() => connectivityService.checkStatus())
          .thenAnswer((_) async => NetworkStatus.offline);
      return NetworkStatusCubit(connectivityService: connectivityService);
    },
    act: (cubit) async {
      statusController.add(NetworkStatus.online);
      await Future<void>.delayed(Duration.zero);
    },
    wait: const Duration(milliseconds: 10),
    expect: () => [
      NetworkStatus.offline,
      NetworkStatus.online,
    ],
  );
}
