import 'package:flutter/material.dart';
import 'package:ondas_mobile/app/router/app_router.dart';
import 'package:ondas_mobile/core/constants/app_constants.dart';
import 'package:ondas_mobile/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.create();

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
