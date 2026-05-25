import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/network/network_status.dart';
import 'package:ondas_mobile/core/network/network_status_cubit.dart';

class ReconnectListener extends StatelessWidget {
  final Widget child;
  final VoidCallback onReconnect;
  final bool Function()? shouldReconnect;

  const ReconnectListener({
    super.key,
    required this.child,
    required this.onReconnect,
    this.shouldReconnect,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkStatusCubit, NetworkStatus>(
      listenWhen: (previous, current) =>
          previous.isOffline && current.isOnline,
      listener: (context, state) {
        if (shouldReconnect?.call() ?? true) {
          onReconnect();
        }
      },
      child: child,
    );
  }
}
