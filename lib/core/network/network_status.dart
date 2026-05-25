enum NetworkStatus {
  unknown,
  online,
  offline,
}

extension NetworkStatusX on NetworkStatus {
  bool get isOnline => this == NetworkStatus.online;
  bool get isOffline => this == NetworkStatus.offline;
}
