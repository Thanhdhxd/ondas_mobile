import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ondas_mobile/core/network/network_status.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService(this._connectivity);

  Future<NetworkStatus> checkStatus() async {
    final result = await _connectivity.checkConnectivity();
    return _mapEvent(result);
  }

  Stream<NetworkStatus> get onStatusChanged =>
      _connectivity.onConnectivityChanged.map(_mapEvent);

  NetworkStatus _mapEvent(dynamic event) {
    if (event is List<ConnectivityResult>) {
      return _mapResults(event);
    }
    if (event is ConnectivityResult) {
      return _mapResult(event);
    }
    return NetworkStatus.offline;
  }

  NetworkStatus _mapResults(List<ConnectivityResult> results) {
    final isOnline = results.any((result) => result != ConnectivityResult.none);
    return isOnline ? NetworkStatus.online : NetworkStatus.offline;
  }

  NetworkStatus _mapResult(ConnectivityResult result) {
    if (result == ConnectivityResult.none) return NetworkStatus.offline;
    return NetworkStatus.online;
  }
}
