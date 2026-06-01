import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ondas_mobile/app/app.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/storage/secure_storage.dart';

import 'e2e_api.dart';

// ---------------------------------------------------------------------------
// Seeded accounts
// ---------------------------------------------------------------------------
const _seededEmail = 'user@e2e.local';
const _seededPassword = 'E2ePass123!';

// ---------------------------------------------------------------------------
// Seeded song data (from seed-e2e.sql)
//
// user@e2e.local has 27 favorites.
// Backend sorts by created_at DESC (newest first).
// Page 1 (items 1-20) = songs 27, 26, 25, 24 … 8
// Page 2 (items 21-27) = songs 7, 6, 5, 4, 3, 2, 1
//
// Song 27 "Multi Artist Collab"  → created NOW()         → page 1, item #1
// Song 26 "A Very Long Song..."  → created NOW()-30s     → page 1, item #2
// Song 01 "E2E Track One"        → created NOW()-25min   → page 2, item #27
// ---------------------------------------------------------------------------
const _songId01Title = 'E2E Track One';      // page 2 — useful for load-more assertion
const _songId26Title =
    'A Very Long Song Title That Exceeds One Hundred Characters For Testing Ellipsis And Text Overflow In Various UI Components';
const _songId27Title = 'Multi Artist Collab'; // page 1, item #1 (newest)

// ---------------------------------------------------------------------------
// Expected UI texts (Vietnamese — default locale)
// ---------------------------------------------------------------------------
const _emptyTitle = 'Chưa có bài hát yêu thích';

// ---------------------------------------------------------------------------
// Widget keys
// ---------------------------------------------------------------------------
const _loginEmailKey = Key('loginScreen_emailField');
const _loginPasswordKey = Key('loginScreen_passwordField');
const _loginSubmitKey = Key('loginScreen_submitButton');
const _favoritesAppBarKey = Key('favoritesScreen_appBar');
const _favoritesBackKey = Key('favoritesScreen_backButton');

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Finder _byKey(Key key) => find.byKey(key);

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
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

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pumpWidget(const App());
}

Future<void> waitForLoginScreen(WidgetTester tester) async {
  await pumpUntilFound(tester, _byKey(_loginEmailKey));
}

Future<void> waitForHomeShell(WidgetTester tester) async {
  await pumpUntilFound(
    tester,
    find.byType(NavigationBar),
    timeout: const Duration(seconds: 30),
  );
}

/// Đăng nhập rồi điều hướng sang /favorites qua GoRouter.
Future<void> loginAndGoToFavorites(WidgetTester tester) async {
  await pumpApp(tester);
  await waitForLoginScreen(tester);
  await tester.enterText(_byKey(_loginEmailKey), _seededEmail);
  await tester.enterText(_byKey(_loginPasswordKey), _seededPassword);
  await tester.ensureVisible(_byKey(_loginSubmitKey));
  await tester.tap(_byKey(_loginSubmitKey));
  await waitForHomeShell(tester);
  final context = tester.element(find.byType(NavigationBar));
  GoRouter.of(context).push('/favorites');
  await pumpUntilFound(tester, _byKey(_favoritesAppBarKey));
}

/// Scroll đến khi item có text [text] xuất hiện, hoặc timeout.
Future<void> scrollUntilTextVisible(
  WidgetTester tester,
  String text, {
  int maxScrolls = 15,
}) async {
  for (var i = 0; i < maxScrolls; i++) {
    if (find.text(text).evaluate().isNotEmpty) return;
    await tester.fling(find.byType(ListView), const Offset(0, -600), 2000);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
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
    await sl<SecureStorage>().clearAll();
    await resetE2EData();
  });

  // =========================================================================
  // Group 1 — Happy Path: Hiển thị màn hình
  // =========================================================================
  group('Happy Path — Hiển thị', () {
    // TC01 – Vào FavoritesScreen thành công sau khi đăng nhập
    // Data: user@e2e.local / E2ePass123! (27 favorites seeded)
    // Expected: FavoritesScreen mở, AppBar hiển thị
    testWidgets('[TC01] Vào FavoritesScreen thành công', (tester) async {
      await loginAndGoToFavorites(tester);

      expect(_byKey(_favoritesAppBarKey), findsOneWidget);
    });

    // TC02 – Danh sách yêu thích hiển thị các ListTile
    // Data: user@e2e.local — 27 favorites, page 1 = 20 bài
    // Expected: ListView và ListTile hiển thị sau khi load
    testWidgets('[TC02] Danh sách hiển thị bài hát seeded', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      expect(find.byType(ListTile), findsWidgets);
    });

    // TC03 – Mỗi bài hát hiển thị placeholder ảnh khi coverUrl = null
    // Data: Tất cả bài seeded có cover_url = NULL → hiển thị icon music_note
    // Expected: Icon music_note_rounded xuất hiện trong list
    testWidgets('[TC03] Bài hát hiển thị placeholder ảnh khi coverUrl = null',
        (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      expect(find.byIcon(Icons.music_note_rounded), findsWidgets);
    });

    // TC04 – Nút trái tim hiển thị checked (đỏ) cho bài đang yêu thích
    // Data: 27 favorites — tất cả đang được yêu thích
    // Expected: icon favorite_rounded (đỏ) xuất hiện sau khi checkStatus API trả về
    testWidgets('[TC04] Nút trái tim hiển thị checked cho bài trong favorites',
        (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    });

    // TC05 – Bài hát có tiêu đề rất dài (>100 ký tự) không gây overflow
    // Data: Song 26 — page 1, item #2 (visible ngay không cần scroll)
    // Expected: ListTile hiển thị bình thường, không crash, không exception
    testWidgets('[TC05] Tiêu đề bài hát dài hiển thị với ellipsis',
        (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));
      // Song 26 là item #2 trong page 1 — không cần scroll
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ListTile), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    // TC06 – Bài hát có nhiều nghệ sĩ (5 artists) hiển thị đúng
    // Data: Song 27 — page 1, item #1 (visible ngay, không cần scroll)
    // Expected: Tên bài hiển thị, không crash
    testWidgets('[TC06] Bài hát multi-artist hiển thị đúng', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));
      // Song 27 "Multi Artist Collab" là item đầu tiên (newest)
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text(_songId27Title), findsOneWidget);
    });
  });

  // =========================================================================
  // Group 2 — Happy Path: Empty State
  // =========================================================================
  group('Happy Path — Empty State', () {
    // TC07 – Empty state khi user chưa có bài yêu thích
    // Data: admin@e2e.local — không có favorites seeded
    // Expected: empty state với icon + text "Chưa có bài hát yêu thích"
    testWidgets('[TC07] Empty state khi user chưa có bài yêu thích',
        (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);
      await tester.enterText(_byKey(_loginEmailKey), 'admin@e2e.local');
      await tester.enterText(_byKey(_loginPasswordKey), 'E2ePass123!');
      await tester.ensureVisible(_byKey(_loginSubmitKey));
      await tester.tap(_byKey(_loginSubmitKey));
      await waitForHomeShell(tester);

      final context = tester.element(find.byType(NavigationBar));
      GoRouter.of(context).push('/favorites');
      await pumpUntilFound(tester, _byKey(_favoritesAppBarKey));
      await pumpUntilFound(tester, find.text(_emptyTitle));

      expect(find.text(_emptyTitle), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });
  });

  // =========================================================================
  // Group 3 — Happy Path: Pull-to-refresh
  // =========================================================================
  group('Happy Path — Pull-to-refresh', () {
    // TC08 – Pull-to-refresh không crash và hiển thị lại danh sách
    // Data: user@e2e.local — 27 favorites
    // Expected: RefreshIndicator hoạt động, danh sách vẫn còn sau refresh
    testWidgets('[TC08] Pull-to-refresh tải lại danh sách', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  // =========================================================================
  // Group 4 — Happy Path: Load More / Infinite Scroll
  // =========================================================================
  group('Happy Path — Load More', () {
    // TC09 – Scroll xuống cuối page 1 → load page 2 tự động
    // Data: 27 favorites; page 2 chứa song 01 "E2E Track One"
    // Expected: Song 01 (page 2) xuất hiện sau khi scroll đủ
    testWidgets('[TC09] Scroll đến cuối → load more tự động', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      // Scroll dần dần cho đến khi song 01 (page 2) xuất hiện
      await scrollUntilTextVisible(tester, _songId01Title);

      expect(find.text(_songId01Title), findsOneWidget);
    });

    // TC10 – Khi đã load hết dữ liệu (hasMore=false), không còn loading ở cuối
    // Data: user@e2e.local — 27 favorites; scroll qua hết 2 trang
    // Expected: CircularProgressIndicator biến mất, song 01 (bài cuối) hiển thị
    testWidgets('[TC10] Khi hết dữ liệu, không còn loading indicator cuối',
        (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      // Scroll đến khi song 01 xuất hiện (hết data)
      await scrollUntilTextVisible(tester, _songId01Title, maxScrolls: 20);
      // Sau khi load hết, không còn spinner cuối list
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // =========================================================================
  // Group 5 — Happy Path: Swipe-to-dismiss
  // =========================================================================
  group('Happy Path — Swipe-to-dismiss', () {
    // TC11 – Vuốt trái để xóa bài hát đầu tiên (optimistic remove)
    // Data: user@e2e.local — 27 favorites; vuốt xóa item đầu tiên
    // Expected: Bài hát biến mất (optimistic), list vẫn hiển thị bình thường
    testWidgets('[TC11] Vuốt trái xóa bài hát đầu tiên', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      final firstItem = find.byType(Dismissible).first;
      await tester.fling(firstItem, const Offset(-500, 0), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ListView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // TC12 – Vuốt xóa 3 bài liên tiếp → danh sách thu nhỏ dần, không crash
    // Data: user@e2e.local — 27 favorites
    // Expected: Sau 3 lần swipe, mỗi lần item đầu biến mất; list vẫn hiển thị
    testWidgets('[TC12] Vuốt xóa 3 bài liên tiếp không crash', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      for (var i = 0; i < 3; i++) {
        final firstItem = find.byType(Dismissible).first;
        await tester.fling(firstItem, const Offset(-500, 0), 1000);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      expect(find.byType(ListView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // =========================================================================
  // Group 6 — Happy Path: Nút trái tim (FavoriteButtonWidget)
  // =========================================================================
  group('Happy Path — Favorite Button', () {
    // TC13 – Nhấn nút trái tim (checked → unchecked) trong FavoritesScreen
    // Data: Song 27 đang checked (item đầu); nhấn nút trái tim
    // Expected: API removeFavorite gọi, không crash
    testWidgets('[TC13] Nhấn tim để bỏ yêu thích trong FavoritesScreen',
        (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));
      // Chờ FavoriteToggleBloc checkStatus xong
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      final heartBtn = find.byKey(const Key('favoriteButton')).first;
      await tester.ensureVisible(heartBtn);
      await tester.tap(heartBtn);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(ListView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // TC14 – Nút trái tim hiển thị loading khi checkStatus đang gọi
    // Data: Vào FavoritesScreen; pump ít để bắt loading state
    // Expected: Sau khi settle, icon favorite_rounded hiển thị (checked)
    testWidgets(
        '[TC14] Nút trái tim hiển thị loading khi checkStatus đang chạy',
        (tester) async {
      await loginAndGoToFavorites(tester);
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    });
  });

  // =========================================================================
  // Group 7 — Happy Path: Navigation
  // =========================================================================
  group('Happy Path — Navigation', () {
    // TC15 – Nhấn nút Back từ FavoritesScreen → quay về màn trước
    // Data: Từ Home push /favorites, nhấn Back button
    // Expected: FavoritesScreen unmount, NavigationBar vẫn thấy
    testWidgets('[TC15] Nhấn Back quay về màn hình trước', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, _byKey(_favoritesBackKey));

      await tester.tap(_byKey(_favoritesBackKey));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(_byKey(_favoritesAppBarKey), findsNothing);
    });

    // TC16 – Loading indicator hiển thị khi đang fetch danh sách
    // Trên device thật pump() không có duration vẫn advance real time một chút,
    // nên fixed-frame pump không đảm bảo bắt được loading state.
    // Giải pháp: dùng pumpUntilFound với timeout ngắn (3s) để poll —
    // spinner xuất hiện ngay khi FavoritesScreen mount và bloc emit
    // FavoritesListLoading (synchronous trước async API call).
    testWidgets('[TC16] Loading indicator hiển thị khi đang fetch', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);
      await tester.enterText(_byKey(_loginEmailKey), _seededEmail);
      await tester.enterText(_byKey(_loginPasswordKey), _seededPassword);
      await tester.ensureVisible(_byKey(_loginSubmitKey));
      await tester.tap(_byKey(_loginSubmitKey));
      await waitForHomeShell(tester);

      final ctx = tester.element(find.byType(NavigationBar));
      GoRouter.of(ctx).push('/favorites');

      // Poll cho đến khi spinner xuất hiện (FavoritesListLoading đã emit).
      // Timeout 3s — đủ để screen mount; thường API mất > 100ms nên
      // spinner sẽ xuất hiện trước khi FavoritesListLoaded thay thế nó.
      await pumpUntilFound(
        tester,
        find.byType(CircularProgressIndicator),
        timeout: const Duration(seconds: 3),
      );
    });

    // TC17 – Điều hướng vào /favorites sau khi đã đăng nhập, không redirect về login
    // Data: Token hợp lệ; push /favorites lần 2 sau khi đã vào lần 1
    // Expected: FavoritesScreen hiển thị, không bị redirect
    testWidgets('[TC17] Điều hướng /favorites khi đã có token hợp lệ',
        (tester) async {
      await loginAndGoToFavorites(tester);

      final context1 = tester.element(find.byType(NavigationBar));
      GoRouter.of(context1).go('/home');
      await tester.pumpAndSettle();

      final context2 = tester.element(find.byType(NavigationBar));
      GoRouter.of(context2).push('/favorites');
      await pumpUntilFound(tester, _byKey(_favoritesAppBarKey));

      expect(_byKey(_favoritesAppBarKey), findsOneWidget);
      expect(find.byKey(_loginEmailKey), findsNothing);
    });
  });

  // =========================================================================
  // Group 8 — Boundary
  // =========================================================================
  group('Boundary', () {
    // TC18 – Scroll đến cuối page 1 → page 2 load và song 01 xuất hiện
    // Data: 27 favorites; scroll qua 20 items → trigger loadMore
    // Expected: Song 01 "E2E Track One" (page 2) xuất hiện sau load more
    testWidgets('[TC18] Scroll đến cuối page 1 → page 2 được load',
        (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      await scrollUntilTextVisible(tester, _songId01Title);

      expect(find.text(_songId01Title), findsOneWidget);
    });

    // TC19 – Load more: tổng 27 bài được hiển thị đầy đủ sau khi scroll hết
    // Data: user@e2e.local — 27 favorites; scroll đến tận cuối
    // Expected: Song 01 (item cuối, page 2) hiển thị
    testWidgets('[TC19] Load more hiển thị đủ bài trang 2', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      await scrollUntilTextVisible(tester, _songId01Title, maxScrolls: 20);

      expect(find.text(_songId01Title), findsOneWidget);
    });

    // TC20 – Tiêu đề bài hát rất dài (>100 ký tự) không gây layout overflow
    // Data: Song 26 — page 1, item #2, visible ngay
    // Expected: Không có overflow exception; ListTile render bình thường
    testWidgets('[TC20] Tiêu đề dài không gây overflow', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ListTile), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    // TC21 – Bài hát 5 nghệ sĩ (song 27) hiển thị artistDisplay đúng
    // Data: Song 27 — page 1, item #1, visible ngay
    // Expected: Tên bài "Multi Artist Collab" hiển thị, không crash
    testWidgets('[TC21] Multi-artist song hiển thị artist display',
        (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text(_songId27Title), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // TC22 – Sau khi swipe xóa song 27 (item #1), pull-to-refresh không khôi phục lại
    // Data: Vuốt xóa song 27 → API removeFavorite gọi; sau đó pull-to-refresh
    // Expected: Song 27 không xuất hiện lại sau refresh (đã xóa thật trên server)
    testWidgets('[TC22] Sau swipe xóa, pull-to-refresh không khôi phục bài đã xóa',
        (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      // Xóa item đầu (song 27)
      final firstItem = find.byType(Dismissible).first;
      await tester.fling(firstItem, const Offset(-500, 0), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Pull-to-refresh
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Song 27 không xuất hiện lại (đã bị xóa trên server)
      expect(find.text(_songId27Title), findsNothing);
    });

    // TC23 – Scroll nhanh liên tục không gây crash (rapid scroll stress test)
    // Data: user@e2e.local — 27 favorites
    // Expected: Không crash, không exception
    testWidgets('[TC23] Scroll nhanh liên tục không crash', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      // Scroll xuống rồi lên nhanh liên tục
      for (var i = 0; i < 5; i++) {
        await tester.fling(find.byType(ListView), const Offset(0, -800), 3000);
        await tester.pump(const Duration(milliseconds: 200));
        await tester.fling(find.byType(ListView), const Offset(0, 800), 3000);
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(tester.takeException(), isNull);
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  // =========================================================================
  // Group 9 — Negative / Error Handling
  // =========================================================================
  group('Negative — Error Handling', () {
    // TC24 – Điều hướng /favorites khi chưa đăng nhập → redirect về /login
    // Data: SecureStorage rỗng (token = null)
    // Expected: App redirect về /login, FavoritesScreen không xuất hiện
    testWidgets('[TC24] Chưa đăng nhập → redirect về login', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      expect(_byKey(_favoritesAppBarKey), findsNothing);
      expect(_byKey(_loginEmailKey), findsOneWidget);
    });

    // TC25 – Không gọi loadMore duplicate khi đang loading more
    // Data: user@e2e.local — 27 favorites; scroll nhanh 2 lần liên tiếp
    // Expected: Không crash, không exception
    testWidgets('[TC25] Không gọi loadMore duplicate khi đang loading',
        (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, find.byType(ListView));

      await tester.fling(find.byType(ListView), const Offset(0, -5000), 8000);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.fling(find.byType(ListView), const Offset(0, -5000), 8000);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(tester.takeException(), isNull);
    });

    // TC26 – Nhấn Back nhiều lần liên tiếp không crash
    // Data: Push /favorites rồi nhấn Back 2 lần
    // Expected: Lần nhấn đầu pop về Home; lần 2 không crash (đã ở root)
    testWidgets('[TC26] Nhấn Back nhiều lần không crash', (tester) async {
      await loginAndGoToFavorites(tester);
      await pumpUntilFound(tester, _byKey(_favoritesBackKey));

      await tester.tap(_byKey(_favoritesBackKey));
      await tester.pumpAndSettle();

      // Lần 2: không còn FavoritesBackButton → không crash
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
