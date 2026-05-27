import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/localization/language_cubit.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:ondas_mobile/features/favorites/presentation/widgets/favorites_list_widget.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/library_bloc.dart';
import 'package:ondas_mobile/features/library/presentation/widgets/playlist_tab_widget.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.watch<LanguageCubit>().state;
    return BlocProvider<LibraryBloc>(
      create: (_) => sl<LibraryBloc>()..add(const LibraryStarted()),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.nearBlack,
          appBar: AppBar(
            backgroundColor: AppColors.nearBlack,
            elevation: 0,
            title: Text(
              t(Str.libraryTitle, l),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            bottom: TabBar(
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.silver,
              indicatorColor: AppColors.spotifyGreen,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              tabs: [
                Tab(key: const Key('libraryScreen_favoriteTab'), text: t(Str.libraryFavoriteTab, l)),
                Tab(key: const Key('libraryScreen_playlistTab'), text: t(Str.libraryPlaylistTab, l)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _FavoriteTab(),
              PlaylistTabWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteTab extends StatelessWidget {
  const _FavoriteTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FavoritesBloc>()..add(const FavoritesListRequested()),
      child: const FavoritesListWidget(),
    );
  }
}

