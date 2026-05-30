import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/app/app.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/storage/secure_storage.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/mini_player_widget.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/player/presentation/screens/player_screen.dart';
import 'e2e_api.dart';

// ---------------------------------------------------------------------------
// Tai khoan seed (co san sau resetE2EData)
// ---------------------------------------------------------------------------
const _seededEmail = 'user@e2e.local';
const _seededPassword = 'E2ePass123!';

// ---------------------------------------------------------------------------
// Widget keys
// ---------------------------------------------------------------------------
const _loginEmailFieldKey = Key('loginScreen_emailField');
const _loginPasswordFieldKey = Key('loginScreen_passwordField');
const _loginSubmitButtonKey = Key('loginScreen_submitButton');

const _trendingSongKey = Key('homeScreen_trendingSong_0');
const _featuredArtistKey = Key('homeScreen_featuredArtist_0');

const _searchFieldKey = Key('searchScreen_searchField');
const _searchResultsKey = Key('searchScreen_resultsList');

const _libraryFavoriteTabKey = Key('libraryScreen_favoriteTab');
const _libraryPlaylistTabKey = Key('libraryScreen_playlistTab');

const _profileHistoryButtonKey = Key('profileScreen_historyButton');

const _playerArtworkKey = Key('playerScreen_artwork');
const _playerControlsKey = Key('playerScreen_controls');
const _playerSeekbarSliderKey = Key('playerSeekbar_slider');
const _playerVolumeSliderKey = Key('playerVolume_slider');
const _playerPlayPauseKey = Key('playerControls_playPauseButton');
const _playerSkipNextKey = Key('playerControls_skipNextButton');
const _playerSkipPreviousKey = Key('playerControls_skipPreviousButton');
const _playerRepeatKey = Key('playerControls_repeatButton');
const _playerBackKey = Key('playerScreen_backButton');
const _playerQueueItemKey = Key('playerQueueTab_item_0');

// ---------------------------------------------------------------------------
// Seed data
// ---------------------------------------------------------------------------
const _songTrackOneId = '66666666-6666-6666-6666-666666666601';
const _songTrackTwoId = '66666666-6666-6666-6666-666666666602';
const _songLongTitleId = '66666666-6666-6666-6666-666666666626';
const _songMultiArtistId = '66666666-6666-6666-6666-666666666627';
const _songZeroDurationId = '66666666-6666-6666-6666-666666666628';
const _songLyricsId = '66666666-6666-6666-6666-666666666630';

const _songTrackOneTitle = 'E2E Track One';
const _songTrackTwoTitle = 'E2E Track Two';
const _songLongTitle =
  'A Very Long Song Title That Exceeds One Hundred Characters For Testing Ellipsis And Text Overflow In Various UI Components';
const _songMultiArtistTitle = 'Multi Artist Collab';
const _songZeroDurationTitle = 'Zero Duration Track';
const _songLyricsTitle = 'Lyrics Track';

const _playlistE2EId = '88888888-8888-8888-8888-888888888881';
const _playlistJazzId = '88888888-8888-8888-8888-888888888884';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Finder _byKey(Key key) => find.byKey(key);

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 25),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure(
    'Timed out waiting for ${finder.describeMatch(Plurality.one)}',
  );
}

/// Pumps every 250ms until [bloc]'s state has a non-zero [Duration].
Future<void> pumpUntilDuration(
  WidgetTester tester,
  PlayerBloc bloc, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
    final d = bloc.state.duration;
    if (d.inMilliseconds > 0) return;
  }
  throw TestFailure('Timed out waiting for PlayerBloc.duration to become available');
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pumpWidget(const App());
}

Future<void> waitForLoginScreen(WidgetTester tester) async {
  await pumpUntilFound(tester, _byKey(_loginEmailFieldKey));
}

Future<void> waitForHomeShell(WidgetTester tester) async {
  await pumpUntilFound(tester, find.byType(NavigationBar));
}

Future<void> _tapBottomNavIcon(
  WidgetTester tester, {
  required IconData primary,
  required IconData fallback,
}) async {
  final navBar = find.byType(NavigationBar);
  Finder iconFinder = find.descendant(of: navBar, matching: find.byIcon(primary));
  if (iconFinder.evaluate().isEmpty) {
    iconFinder = find.descendant(of: navBar, matching: find.byIcon(fallback));
  }
  if (iconFinder.evaluate().isEmpty) {
    throw TestFailure('Could not find bottom nav icon: $primary');
  }
  await tester.tap(iconFinder.first);
  await tester.pumpAndSettle();
}

Future<void> openSearchTab(WidgetTester tester) async {
  await _tapBottomNavIcon(
    tester,
    primary: Icons.search,
    fallback: Icons.search_outlined,
  );
  await pumpUntilFound(tester, _byKey(_searchFieldKey));
}

Future<void> openLibraryTab(WidgetTester tester) async {
  await _tapBottomNavIcon(
    tester,
    primary: Icons.library_music,
    fallback: Icons.library_music_outlined,
  );
  await tester.pumpAndSettle();
}

Future<void> openProfileTab(WidgetTester tester) async {
  await _tapBottomNavIcon(
    tester,
    primary: Icons.person,
    fallback: Icons.person_outline,
  );
  await tester.pumpAndSettle();
}

Future<void> submitSearch(WidgetTester tester, String query) async {
  await openSearchTab(tester);
  await tester.enterText(_byKey(_searchFieldKey), query);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 700));
  await pumpUntilFound(tester, _byKey(_searchResultsKey));
}

Future<void> tapSearchSongById(WidgetTester tester, String songId) async {
  final tileKey = Key('searchScreen_songTile_$songId');
  await pumpUntilFound(tester, _byKey(tileKey));
  await tester.tap(_byKey(tileKey));
  await tester.pumpAndSettle();
}

Future<void> openArtistSongListFromHome(WidgetTester tester) async {
  await pumpUntilFound(tester, _byKey(_featuredArtistKey));
  await tester.tap(_byKey(_featuredArtistKey));
  await pumpUntilFound(tester, _byKey(const Key('songListScreen_scaffold')));
}

Future<void> tapFirstSongInSongList(WidgetTester tester) async {
  final listFinder = _byKey(const Key('songListScreen_list'));
  await pumpUntilFound(tester, listFinder);
  final tileFinder = find.descendant(
    of: listFinder,
    matching: find.byType(ListTile),
  );
  await tester.tap(tileFinder.first);
  await tester.pumpAndSettle();
}

Future<void> openFavoritesFromLibrary(WidgetTester tester) async {
  await openLibraryTab(tester);
  await tester.tap(_byKey(_libraryFavoriteTabKey));
  await tester.pumpAndSettle();
}

Future<void> openPlaylistsFromLibrary(WidgetTester tester) async {
  await openLibraryTab(tester);
  await tester.tap(_byKey(_libraryPlaylistTabKey));
  await tester.pumpAndSettle();
}

Future<void> openPlaylistDetail(WidgetTester tester, String playlistId) async {
  await openPlaylistsFromLibrary(tester);
  final itemFinder = find.byKey(ValueKey('libraryPlaylistItem_$playlistId'));
  await pumpUntilFound(tester, itemFinder);
  await tester.tap(itemFinder);
  await tester.pumpAndSettle();
  await pumpUntilFound(tester, _byKey(const Key('playlistDetailScreen_editButton')));
}

Future<void> openPlayerRoute(WidgetTester tester) async {
  final navBar = find.byType(NavigationBar);
  await pumpUntilFound(tester, navBar);
  final context = tester.element(navBar);
  await tester.runAsync(() async {
    GoRouter.of(context).push('/player');
  });
  await tester.pumpAndSettle();
}

Future<void> openPlayerFromMini(WidgetTester tester) async {
  await pumpUntilFound(tester, find.byType(MiniPlayerWidget));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.tap(find.byType(MiniPlayerWidget), warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> ensurePlayerScreen(WidgetTester tester) async {
  if (_byKey(_playerArtworkKey).evaluate().isNotEmpty) return;
  if (find.byType(MiniPlayerWidget).evaluate().isEmpty) {
    final backFinder = find.byIcon(Icons.arrow_back);
    if (backFinder.evaluate().isNotEmpty) {
      await tester.tap(backFinder.first);
      await tester.pumpAndSettle();
    }
  }
  await openPlayerFromMini(tester);
}

Future<void> openLyricsTab(WidgetTester tester) async {
  final pageView = tester.widget<PageView>(find.byType(PageView));
  pageView.controller!.jumpToPage(1);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> openQueueTab(WidgetTester tester) async {
  final pageView = tester.widget<PageView>(find.byType(PageView));
  pageView.controller!.jumpToPage(2);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> loginAsSeededUser(WidgetTester tester) async {
  await pumpApp(tester);
  await waitForLoginScreen(tester);

  await tester.enterText(_byKey(_loginEmailFieldKey), _seededEmail);
  await tester.enterText(_byKey(_loginPasswordFieldKey), _seededPassword);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.tap(_byKey(_loginSubmitButtonKey));

  await waitForHomeShell(tester);
}

Future<void> openPlayerFromTrending(WidgetTester tester) async {
  await pumpUntilFound(tester, _byKey(_trendingSongKey));
  await tester.tap(_byKey(_trendingSongKey));
  await pumpUntilFound(tester, find.byType(MiniPlayerWidget));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.tap(find.byType(MiniPlayerWidget), warnIfMissed: false);
  await tester.pumpAndSettle();
}

Icon _firstIcon(WidgetTester tester, Finder finder) {
  final icon = tester.widgetList<Icon>(finder).first;
  return icon;
}

Icon _iconInControls(WidgetTester tester, IconData iconData) {
  final controls = _byKey(_playerControlsKey);
  final finder = find.descendant(of: controls, matching: find.byIcon(iconData));
  return tester.widgetList<Icon>(finder).first;
}

Icon _leadingVolumeIcon(WidgetTester tester) {
  final volume = _byKey(const Key('playerScreen_volume'));
  final finder = find.descendant(of: volume, matching: find.byType(Icon));
  return tester.widgetList<Icon>(finder).first;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await sl.reset();
    await setupDependencies();
  });

  setUp(() async {
    // Give just_audio's internal proxy HTTP server 500ms to finish serving
    // any in-flight requests from the previous test before calling stop().
    // Without this delay, the proxy crashes with a null-check error on
    // teardown (a known just_audio limitation).
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await sl<AudioPlayerService>().stop();
    await sl<SecureStorage>().clearAll();
    await resetE2EData();
  });

  // =========================================================================
  // Happy Path
  // =========================================================================
  group('Happy Path', () {
    // TC01 – Phat mot bai hat tu danh sach bai hat (SongListScreen)
    // Data: Artist song list (Home featured artist)
    // Expected: PlayerScreen mo ra, bai hat bat dau phat
    testWidgets('[TC01] Phat mot bai hat tu danh sach bai hat', (tester) async {
      await loginAsSeededUser(tester);
      await openArtistSongListFromHome(tester);

      await tapFirstSongInSongList(tester);
      await ensurePlayerScreen(tester);

      await pumpUntilFound(tester, _byKey(_playerArtworkKey));
    });

    // TC02 – Phat mot bai hat tu ket qua tim kiem
    // Data: Keyword = E2E Track One
    // Expected: PlayerScreen mo ra
    testWidgets('[TC02] Phat mot bai hat tu ket qua tim kiem', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, _songTrackOneTitle);

      await tapSearchSongById(tester, _songTrackOneId);
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerArtworkKey));
    });

    // TC03 – Phat mot bai hat tu danh sach yeu thich
    // Data: Favorites co E2E Track One
    // Expected: PlayerScreen mo ra
    testWidgets('[TC03] Phat mot bai hat tu danh sach yeu thich', (tester) async {
      await loginAsSeededUser(tester);
      // Re-favorite Track One so it gets createdAt=NOW() and appears on page 0
      // (seed has 27 favorites sorted DESC; Track One is the oldest = page 1).
      await likeSong(_songTrackOneId);
      await openFavoritesFromLibrary(tester);

      await pumpUntilFound(tester, find.text(_songTrackOneTitle));
      await tester.tap(find.text(_songTrackOneTitle));
      await tester.pumpAndSettle();

      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerArtworkKey));
    });

    // TC04 – Phat mot bai hat tu Playlist Detail
    // Data: Playlist E2E (2 songs)
    // Expected: PlayerScreen mo ra
    testWidgets('[TC04] Phat mot bai hat tu Playlist Detail', (tester) async {
      await loginAsSeededUser(tester);
      await openPlaylistDetail(tester, _playlistE2EId);

      await pumpUntilFound(tester, find.text(_songTrackOneTitle));
      await tester.tap(find.text(_songTrackOneTitle));
      await tester.pumpAndSettle();

      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerArtworkKey));
    });

    // TC05 – Pause/Resume tren Player
    // Data: Bai dang phat
    // Expected: Play/Pause icon thay doi
    testWidgets('[TC05] Pause/Resume tren Player', (tester) async {
      await loginAsSeededUser(tester);
      await openPlayerFromTrending(tester);

      await pumpUntilFound(tester, _byKey(_playerControlsKey));
      // Scope to PlayerScreen: only PlayerScreen wraps its controls with
      // Key('playerScreen_controls') — MiniPlayer does not.
      final playPauseFinder = find.descendant(
        of: _byKey(_playerControlsKey),
        matching: _byKey(_playerPlayPauseKey),
      );
      await tester.tap(playPauseFinder);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);

      await tester.tap(playPauseFinder);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.pause_rounded), findsWidgets);
    });

    // TC06 – Chuyen bai tiep theo (Skip Next)
    // Data: Queue nhieu bai
    // Expected: Khong crash
    testWidgets('[TC06] Chuyen bai tiep theo (Skip Next)', (tester) async {
      await loginAsSeededUser(tester);
      await openPlayerFromTrending(tester);

      await pumpUntilFound(tester, _byKey(_playerControlsKey));
      final skipNextFinder = find.descendant(
        of: _byKey(_playerControlsKey),
        matching: _byKey(_playerSkipNextKey),
      );
      await tester.tap(skipNextFinder);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.descendant(
        of: _byKey(_playerControlsKey),
        matching: _byKey(_playerPlayPauseKey),
      ), findsWidgets);
    });

    // TC07 – Skip Previous (bai da phat > 3s)
    // Expected: tua ve dau bai
    testWidgets('[TC07] Skip Previous > 3s', (tester) async {
      await loginAsSeededUser(tester);
      await openPlaylistDetail(tester, _playlistE2EId);

      await pumpUntilFound(tester, find.text(_songTrackOneTitle));
      await tester.tap(find.text(_songTrackOneTitle));
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerSeekbarSliderKey));

      final playerCtx = tester.element(find.byType(PlayerScreen));
      final playerBloc = playerCtx.read<PlayerBloc>();
      await pumpUntilDuration(tester, playerBloc);

      playerBloc.add(const SeekRequested(Duration(seconds: 5)));
      await tester.pumpAndSettle();

      final skipPreviousFinder = find.descendant(
        of: _byKey(_playerControlsKey),
        matching: _byKey(_playerSkipPreviousKey),
      );
      await tester.tap(skipPreviousFinder);
      await tester.pumpAndSettle();

      expect(playerBloc.state.currentSong?.title, _songTrackOneTitle);
    });

    // TC08 – Skip Previous (bai moi phat < 3s)
    // Expected: chuyen ve bai truoc do
    testWidgets('[TC08] Skip Previous < 3s', (tester) async {
      await loginAsSeededUser(tester);
      await openPlaylistDetail(tester, _playlistE2EId);

      await pumpUntilFound(tester, find.text(_songTrackTwoTitle));
      await tester.tap(find.text(_songTrackTwoTitle));
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerSeekbarSliderKey));

      final playerCtx = tester.element(find.byType(PlayerScreen));
      final playerBloc = playerCtx.read<PlayerBloc>();
      await pumpUntilDuration(tester, playerBloc);

      final skipPreviousFinder = find.descendant(
        of: _byKey(_playerControlsKey),
        matching: _byKey(_playerSkipPreviousKey),
      );
      await tester.tap(skipPreviousFinder);
      await tester.pumpAndSettle();

      expect(playerBloc.state.currentSong?.title, _songTrackOneTitle);
    });

    // TC09 – Seek den vi tri cu the
    // Data: Bai dang phat
    // Expected: Seekbar van hoat dong
    testWidgets('[TC09] Seek den vi tri cu the', (tester) async {
      await loginAsSeededUser(tester);
      await openPlayerFromTrending(tester);

      await pumpUntilFound(tester, _byKey(_playerSeekbarSliderKey));
      await tester.drag(_byKey(_playerSeekbarSliderKey), const Offset(180, 0));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_byKey(_playerSeekbarSliderKey), findsOneWidget);
    });

    // TC10 – Dieu chinh am luong
    // Data: Bai dang phat
    // Expected: Volume slider hoat dong
    testWidgets('[TC10] Dieu chinh am luong', (tester) async {
      await loginAsSeededUser(tester);
      await openPlayerFromTrending(tester);

      await pumpUntilFound(tester, _byKey(_playerVolumeSliderKey));
      await tester.drag(_byKey(_playerVolumeSliderKey), const Offset(-120, 0));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_byKey(_playerVolumeSliderKey), findsOneWidget);
    });

    // TC11 – Repeat mode toggle
    // Data: Repeat mode off
    // Expected: Off -> All -> One -> Off
    testWidgets('[TC11] Repeat mode toggle', (tester) async {
      await loginAsSeededUser(tester);
      await openPlayerFromTrending(tester);

      await pumpUntilFound(tester, _byKey(_playerControlsKey));
      await tester.tap(_byKey(_playerRepeatKey));
      await tester.pump(const Duration(milliseconds: 300));

      final repeatIcon = _firstIcon(tester, find.byIcon(Icons.repeat_rounded));
      expect(repeatIcon.color, AppColors.spotifyGreen);

      await tester.tap(_byKey(_playerRepeatKey));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.repeat_one_rounded), findsWidgets);

      await tester.tap(_byKey(_playerRepeatKey));
      await tester.pump(const Duration(milliseconds: 300));
      final repeatIconAfter =
          _firstIcon(tester, find.byIcon(Icons.repeat_rounded));
      expect(repeatIconAfter.color, AppColors.silver);
    });

    // TC12 – Mini Player hien thi dung bai hat dang phat
    // Data: Dang phat nhac
    // Expected: Dong Player, mo lai tu Mini Player
    testWidgets('[TC12] Mini Player mo lai Player', (tester) async {
      await loginAsSeededUser(tester);
      await openPlayerFromTrending(tester);

      await pumpUntilFound(tester, _byKey(_playerBackKey));
      await tester.tap(_byKey(_playerBackKey));
      await tester.pumpAndSettle();

      await pumpUntilFound(tester, find.byType(MiniPlayerWidget));
      await tester.tap(find.byType(MiniPlayerWidget));
      await pumpUntilFound(tester, _byKey(_playerArtworkKey));
    });

    // TC13 – Tab Queue hien thi dung danh sach cho
    // Data: Queue co bai
    // Expected: Queue tab hien danh sach
    testWidgets('[TC13] Tab Queue hien thi dung danh sach cho', (tester) async {
      await loginAsSeededUser(tester);
      await openPlayerFromTrending(tester);
      // Wait for the PlayerScreen's PageView to be fully mounted before
      // calling openQueueTab (which drags the PageView).
      await pumpUntilFound(tester, _byKey(_playerArtworkKey));

      // openQueueTab drags PageView twice (Info→Lyrics→Queue).
      // tapPlayerTab was failing because the tab label text doesn't exist in the tree.
      await openQueueTab(tester);
      await pumpUntilFound(tester, _byKey(_playerQueueItemKey));
      expect(_byKey(_playerQueueItemKey), findsOneWidget);
    });

    // TC14 – Chon bai tiep theo trong Queue
    // Data: Playlist E2E (2 bai) — queue co bai tiep theo
    // Expected: Queue item 1 active after tap
    testWidgets('[TC14] Chon bai tiep theo trong Queue', (
      tester,
    ) async {
      await loginAsSeededUser(tester);
      await openPlaylistDetail(tester, _playlistE2EId);

      await pumpUntilFound(tester, find.text(_songTrackOneTitle));
      await tester.tap(find.text(_songTrackOneTitle));
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerSeekbarSliderKey));

      final playerCtx = tester.element(find.byType(PlayerScreen));
      final playerBloc = playerCtx.read<PlayerBloc>();
      await pumpUntilDuration(tester, playerBloc);

      await openQueueTab(tester);

      final queueItem1 = _byKey(const Key('playerQueueTab_item_1'));
      await pumpUntilFound(tester, queueItem1);
      expect(find.text(_songTrackTwoTitle), findsOneWidget);

      await tester.ensureVisible(queueItem1);
      await tester.tap(queueItem1);

      await pumpUntilFound(
        tester,
        find.descendant(
          of: queueItem1,
          matching: find.byIcon(Icons.equalizer_rounded),
        ),
      );
    });

    // TC15 – Ghi nhan lich su phat (Play History)
    // Data: E2E Track Two
    // Expected: History list co bai vua phat
    testWidgets('[TC15] Ghi nhan lich su phat (Play History)', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, _songTrackTwoTitle);

      await tapSearchSongById(tester, _songTrackTwoId);
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerBackKey));
      // Give the play-history API time to record before navigating away.
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(_byKey(_playerBackKey));
      await tester.pumpAndSettle();

      await openProfileTab(tester);
      await pumpUntilFound(tester, _byKey(_profileHistoryButtonKey));
      await tester.tap(_byKey(_profileHistoryButtonKey));
      await tester.pumpAndSettle();

      await pumpUntilFound(tester, _byKey(const Key('historyScreen_list')));
      // Use pumpUntilFound so we wait for async list rendering.
      await pumpUntilFound(tester, find.text(_songTrackTwoTitle));
    });

    // TC16 – Tab Lyrics hien thi loi bai hat (co lyrics)
    // Data: Lyrics Track (hasSynced=true)
    // Expected: Dong lyrics synced hien thi
    testWidgets('[TC16] Tab Lyrics hien thi loi bai hat', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, _songLyricsTitle);

      await tapSearchSongById(tester, _songLyricsId);
      await ensurePlayerScreen(tester);
      // Wait for the PlayerScreen's PageView to be rendered before dragging.
      await pumpUntilFound(tester, _byKey(_playerArtworkKey));

      await openLyricsTab(tester);
      await pumpUntilFound(tester, find.text('This is the first line of the lyrics'));
    });

  });

  // =========================================================================
  // Boundary
  // =========================================================================
  group('Boundary', () {
    // TC17 – Phat bai hat dau tien trong danh sach
    // Data: Playlist E2E, song index 0
    // Expected: Skip previous disabled
    testWidgets('[TC17] Phat bai hat dau tien trong danh sach', (tester) async {
      await loginAsSeededUser(tester);
      await openPlaylistDetail(tester, _playlistE2EId);

      await pumpUntilFound(tester, find.text(_songTrackOneTitle));
      await tester.tap(find.text(_songTrackOneTitle));
      await tester.pumpAndSettle();

      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerControlsKey));

      final prevIcon = _iconInControls(tester, Icons.skip_previous_rounded);
      expect(prevIcon.color, AppColors.silver);
    });

    // TC18 – Phat bai hat cuoi cung trong danh sach
    // Data: Playlist E2E, song index 1
    // Expected: Skip next disabled
    testWidgets('[TC18] Phat bai hat cuoi cung trong danh sach', (tester) async {
      await loginAsSeededUser(tester);
      await openPlaylistDetail(tester, _playlistE2EId);

      await pumpUntilFound(tester, find.text(_songTrackOneTitle));
      await tester.tap(find.text(_songTrackOneTitle));
      await tester.pumpAndSettle();

      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerControlsKey));
      // TC18: play the last song directly to avoid the skip-next hit-test issue
      // (the skip button is inside the PageView and taps are intercepted).
      // The test goal is that skip-next is disabled on the last song — achieve
      // that by playing Track Two (song 1 / last) from the start instead.
      //
      // Go back to playlist and tap Track Two directly.
      await tester.tap(_byKey(_playerBackKey));
      await tester.pumpAndSettle();

      await pumpUntilFound(tester, find.text(_songTrackTwoTitle));
      await tester.tap(find.text(_songTrackTwoTitle));
      await tester.pumpAndSettle();

      // Tapping a song in playlist detail navigates directly to the full
      // PlayerScreen — no MiniPlayer step. Wait for artwork to confirm.
      await pumpUntilFound(tester, _byKey(_playerArtworkKey));
      await pumpUntilFound(tester, _byKey(_playerControlsKey));
      await tester.pump(const Duration(milliseconds: 400));

      final nextIcon = _iconInControls(tester, Icons.skip_next_rounded);
      expect(nextIcon.color, AppColors.silver);
    });

    // TC19 – Queue chi co 1 bai hat
    // Data: Playlist Jazz (1 song)
    // Expected: Skip next/prev disabled
    testWidgets('[TC19] Queue chi co 1 bai hat', (tester) async {
      await loginAsSeededUser(tester);
      await openPlaylistDetail(tester, _playlistJazzId);

      await pumpUntilFound(tester, find.byType(ListTile));
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerControlsKey));

      final prevIcon = _iconInControls(tester, Icons.skip_previous_rounded);
      final nextIcon = _iconInControls(tester, Icons.skip_next_rounded);
      expect(prevIcon.color, AppColors.silver);
      expect(nextIcon.color, AppColors.silver);
    });

    // TC20 – Bai hat co duration = 0
    // Data: Zero Duration Track
    // Expected: 00:00 display
    testWidgets('[TC20] Bai hat co duration = 0', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, _songZeroDurationTitle);

      await tapSearchSongById(tester, _songZeroDurationId);
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerSeekbarSliderKey));

      expect(find.text('00:00'), findsWidgets);
    });

    // TC21 – Bai hat co duration cực dài (>= 3 giờ)
    // Data: Three Hour Marathon Mix (duration = 10800s)
    // Expected: Hiển thị 3:00:00 trên seekbar
    testWidgets('[TC21] Bai hat co duration cuc dai (>= 3 gio)', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, 'Three Hour Marathon Mix');

      await tapSearchSongById(tester, '66666666-6666-6666-6666-666666666629');
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerSeekbarSliderKey));

      expect(find.text('3:00:00'), findsOneWidget);
    });

    // TC22 – Tua ve vi tri 0:00
    // Expected: Seek to start
    testWidgets('[TC22] Tua ve vi tri 0:00', (tester) async {
      await loginAsSeededUser(tester);
      await openPlayerFromTrending(tester);

      await pumpUntilFound(tester, _byKey(_playerSeekbarSliderKey));
      final playerCtx = tester.element(find.byType(PlayerScreen));
      final playerBloc = playerCtx.read<PlayerBloc>();
      await pumpUntilDuration(tester, playerBloc);

      playerBloc.add(const SeekRequested(Duration.zero));
      await tester.pumpAndSettle();

      expect(playerBloc.state.position.inMilliseconds.abs(), lessThan(500));
    });

    // TC233 – Am luong = 0 (Muted)
    // Data: E2E Track One
    // Expected: Volume icon off
    testWidgets('[TC23] Am luong = 0 (Muted)', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, _songTrackOneTitle);

      await tapSearchSongById(tester, _songTrackOneId);
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerVolumeSliderKey));

      await tester.drag(_byKey(_playerVolumeSliderKey), const Offset(-300, 0));
      await tester.pump(const Duration(milliseconds: 300));
      final mutedIcon = _leadingVolumeIcon(tester);
      expect(mutedIcon.icon, Icons.volume_off_rounded);
    });

    // TC24 – Am luong = 1.0 (Toi da)
    // Data: E2E Track One
    // Expected: Volume icon up
    testWidgets('[TC24] Am luong = 1.0 (Toi da)', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, _songTrackOneTitle);

      await tapSearchSongById(tester, _songTrackOneId);
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerVolumeSliderKey));

      await tester.drag(_byKey(_playerVolumeSliderKey), const Offset(300, 0));
      await tester.pump(const Duration(milliseconds: 300));
      final loudIcon = _leadingVolumeIcon(tester);
      expect(loudIcon.icon, Icons.volume_up_rounded);
    });

    // TC25 – Tieu de bai hat qua dai
    // Data: Long title track
    // Expected: Title text visible
    testWidgets('[TC25] Tieu de bai hat qua dai', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, _songLongTitle);

      await tapSearchSongById(tester, _songLongTitleId);
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerArtworkKey));

      // The title appears in multiple places (search field, result tile,
      // player title, mini player) — use findsWidgets instead of findsOneWidget.
      expect(find.text(_songLongTitle), findsWidgets);
    });

    // TC26 – Ten nghe si nhieu nghe si
    // Data: Multi Artist Collab
    // Expected: Title text visible
    testWidgets('[TC26] Ten nghe si nhieu nghe si', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, _songMultiArtistTitle);

      await tapSearchSongById(tester, _songMultiArtistId);
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerArtworkKey));

      expect(find.text(_songMultiArtistTitle), findsWidgets);
    });

    // TC27 – Anh bia bai hat = null
    // Data: E2E Track One (coverUrl = null in SQL)
    // Expected: Hiển thị placeholder/mặc định thay cho artwork
    testWidgets('[TC27] Anh bia bai hat = null', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, _songTrackOneTitle);

      await tapSearchSongById(tester, _songTrackOneId);
      await ensurePlayerScreen(tester);
      
      final artworkFinder = _byKey(_playerArtworkKey);
      await pumpUntilFound(tester, artworkFinder);
      expect(find.descendant(of: artworkFinder, matching: find.byIcon(Icons.music_note)), findsOneWidget);
    });

    // TC28 – Tua lien tuc (rapid seek)
    testWidgets('[TC28] Tua lien tuc (rapid seek)', (tester) async {
      await loginAsSeededUser(tester);
      // Use Trending (same stable source as TC22) so the audio URL is
      // guaranteed valid and avoids pumpAndSettle inside tapSearchSongById.
      await openPlayerFromTrending(tester);

      await pumpUntilFound(tester, _byKey(_playerControlsKey));
      // Seekbar only appears once duration is known — wait for it explicitly.
      await pumpUntilFound(tester, _byKey(_playerSeekbarSliderKey));
      // Ensure the seekbar is scrolled into view inside the SingleChildScrollView.
      await tester.ensureVisible(_byKey(_playerSeekbarSliderKey));
      await tester.pump(const Duration(milliseconds: 300));

      for (var i = 0; i < 4; i += 1) {
        // Re-verify seekbar is still visible before each drag.
        await pumpUntilFound(tester, _byKey(_playerSeekbarSliderKey),
            timeout: const Duration(seconds: 5));
        await tester.drag(_byKey(_playerSeekbarSliderKey), const Offset(60, 0));
        await tester.pump(const Duration(milliseconds: 200));
      }
      // Final check: seekbar still present after rapid seeks.
      await pumpUntilFound(tester, _byKey(_playerSeekbarSliderKey));
    });

    // TC29 – Nhan Play/Pause lien tuc
    testWidgets('[TC29] Nhan Play/Pause lien tuc', (tester) async {
      await loginAsSeededUser(tester);
      await submitSearch(tester, _songTrackOneTitle);

      await tapSearchSongById(tester, _songTrackOneId);
      await ensurePlayerScreen(tester);
      await pumpUntilFound(tester, _byKey(_playerControlsKey));
      final playPauseFinder = find.descendant(
        of: _byKey(_playerControlsKey),
        matching: _byKey(_playerPlayPauseKey),
      );

      for (var i = 0; i < 8; i += 1) {
        await tester.tap(playPauseFinder);
        await tester.pump(const Duration(milliseconds: 120));
      }

      expect(playPauseFinder, findsWidgets);
    });

    // TC30 – Queue rong khi khoi tao PlayerState
    // Data: No song playing
    // Expected: Idle view shown
    testWidgets('[TC30] Queue rong khi khoi tao PlayerState', (tester) async {
      await loginAsSeededUser(tester);
      await openPlayerRoute(tester);
      // Allow the PlayerBloc idle state to propagate to the UI.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.music_off_rounded), findsOneWidget);
    });
  });
}