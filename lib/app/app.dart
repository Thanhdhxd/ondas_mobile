import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/app/router/app_router.dart';
import 'package:ondas_mobile/core/constants/app_constants.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/network/network_status.dart';
import 'package:ondas_mobile/core/network/network_status_cubit.dart';
import 'package:ondas_mobile/core/theme/app_theme.dart';
import 'package:ondas_mobile/core/widgets/offline_banner.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/core/localization/language_cubit.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.create();

    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayerBloc>(
          create: (_) => sl<PlayerBloc>(),
        ),
        BlocProvider<NetworkStatusCubit>(
          create: (_) => sl<NetworkStatusCubit>(),
        ),
        BlocProvider<LanguageCubit>(
          create: (_) => sl<LanguageCubit>()..loadSavedLanguage(),
        ),
      ],
      child: BlocBuilder<LanguageCubit, String>(
        builder: (context, lang) {
          return BlocBuilder<NetworkStatusCubit, NetworkStatus>(
            builder: (context, status) {
              return MaterialApp.router(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.dark,
                routerConfig: router,
                builder: (context, child) {
                  final content = child ?? const SizedBox.shrink();
                  return Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: status.isOffline
                            ? OfflineBanner(
                                key: const ValueKey('offline_banner'),
                                message: t(Str.offlineMessage, lang),
                              )
                            : const SizedBox.shrink(key: ValueKey('online_spacer')),
                      ),
                      Expanded(child: content),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
