import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/di/injection.dart';
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
    return BlocProvider<LibraryBloc>(
      create: (_) => sl<LibraryBloc>()..add(const LibraryStarted()),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.nearBlack,
          appBar: AppBar(
            backgroundColor: AppColors.nearBlack,
            elevation: 0,
            title: const Text(
              'Library',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            bottom: const TabBar(
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.silver,
              indicatorColor: AppColors.spotifyGreen,
              indicatorWeight: 2.5,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              tabs: [
                Tab(key: Key('libraryScreen_favoriteTab'), text: 'Favorite'),
                Tab(key: Key('libraryScreen_playlistTab'), text: 'Playlist'),
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

