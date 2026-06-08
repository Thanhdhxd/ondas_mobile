import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:ondas_mobile/features/stats/presentation/bloc/stats_event.dart';
import 'package:ondas_mobile/features/stats/presentation/bloc/stats_state.dart';
import 'package:ondas_mobile/features/stats/presentation/widgets/listening_time_card.dart';
import 'package:ondas_mobile/features/stats/presentation/widgets/top_item_tile.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(LoadStats());
  }

  @override
  Widget build(BuildContext context) {
    final langCode = lang(context);

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t(Str.statsTitle, langCode),
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state.status == StatsStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.spotifyGreen),
            );
          }

          if (state.status == StatsStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.negativeRed, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? t(Str.unknownError, langCode),
                    style: const TextStyle(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<StatsBloc>().add(LoadStats()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.spotifyGreen,
                      foregroundColor: AppColors.white,
                    ),
                    child: Text(t(Str.retry, langCode)),
                  ),
                ],
              ),
            );
          }

          if (state.status == StatsStatus.loaded) {
            return RefreshIndicator(
              color: AppColors.spotifyGreen,
              backgroundColor: AppColors.darkCard,
              onRefresh: () async {
                context.read<StatsBloc>().add(LoadStats());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.listeningTime != null)
                      ListeningTimeCard(stats: state.listeningTime!),
                    
                    if (state.topSongs.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        t(Str.statsTopSongs, langCode),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.topSongs.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final song = entry.value;
                        return TopItemTile(
                          index: index,
                          title: song.title,
                          subtitle: song.artistDisplay,
                          imageUrl: song.coverUrl,
                          playCount: song.playCount,
                          isArtist: false,
                        );
                      }),
                    ],

                    if (state.topArtists.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        t(Str.statsTopArtists, langCode),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.topArtists.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final artist = entry.value;
                        return TopItemTile(
                          index: index,
                          title: artist.name,
                          subtitle: '',
                          imageUrl: artist.avatarUrl,
                          playCount: artist.playCount,
                          isArtist: true,
                        );
                      }),
                    ],
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
