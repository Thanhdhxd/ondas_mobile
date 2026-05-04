import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:ondas_mobile/features/favorites/presentation/widgets/favorites_list_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FavoritesBloc>()..add(const FavoritesListRequested()),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        key: const Key('favoritesScreen_appBar'),
        backgroundColor: AppColors.nearBlack,
        title: const Text(
          'Y�u th�ch',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          key: const Key('favoritesScreen_backButton'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const FavoritesListWidget(),
    );
  }
}
