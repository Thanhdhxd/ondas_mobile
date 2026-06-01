import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ondas_mobile/app/app.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/storage/secure_storage.dart';

import 'e2e_api.dart';

// ---------------------------------------------------------------------------
// Seeded accounts (luôn có sẵn sau resetE2EData)
// ---------------------------------------------------------------------------
const _seededEmail = 'user@e2e.local';
const _seededPassword = 'E2ePass123!';
const _adminEmail = 'admin@e2e.local';
const _adminPassword = 'E2ePass123!';
const _inactiveEmail = 'inactive@e2e.local';
const _disabledEmail = 'disabled@e2e.local';

const _maxLocalLength = 64;
String _buildMaxEmail() {
  final local = List.filled(_maxLocalLength, 'a').join();
  // domain 63+1+63+1+62 = 190 → total local(64) + '@'(1) + domain(190) = 255
  final domain = [
    List.filled(63, 'b').join(),
    List.filled(63, 'c').join(),
    List.filled(62, 'd').join(),
  ].join('.');
  return '$local@$domain';
}

String _buildMaxPassword() {
  final chars = List.filled(128, 'a').join();
  return chars;
}

const _minEmail = 'a@b.cd';
const _minEmailInvalid = 'a@b.c';

const _minPassword = 'Abc@12';
const _minPasswordInvalid = 'Abc@1';

final _maxEmail = _buildMaxEmail();
final _maxEmailInvalid = '${_maxEmail}a';

final _maxPassword = _buildMaxPassword();
final _maxPasswordInvalid = '${_maxPassword}a';

const _wrongPassword = 'Wrong#123';

// ---------------------------------------------------------------------------
// Expected error messages (khớp với UI hiển thị)
// ---------------------------------------------------------------------------
const _unauthorizedMessage = 'Unauthorized';
const _emailRequiredMessage = 'Vui lòng nhập email';
const _passwordRequiredMessage = 'Vui lòng nhập mật khẩu';
const _emailInvalidMessage = 'Email không hợp lệ';
const _passwordTooShortMessage = 'Mật khẩu phải có ít nhất 6 ký tự';
const _passwordTooLongMessage = 'Mật khẩu tối đa 128 ký tự';
const _emailTooLongMessage = 'Email tối đa 255 ký tự';
// HTTP 423: DioFailureMapper._extractMessage() đọc data['message'] từ ApiResponse
// backend → "error.account_locked" (raw error code, chưa được i18n phía client)
const _accountLockedMessage = 'error.account_locked';

// ---------------------------------------------------------------------------
// Widget keys
// ---------------------------------------------------------------------------
const _emailFieldKey = Key('loginScreen_emailField');
const _passwordFieldKey = Key('loginScreen_passwordField');
const _submitButtonKey = Key('loginScreen_submitButton');
const _forgotPasswordButtonKey = Key('loginScreen_forgotPasswordButton');
const _goToRegisterButtonKey = Key('loginScreen_goToRegisterButton');
const _forgotPasswordEmailFieldKey = Key('forgotPasswordScreen_emailField');
const _registerEmailFieldKey = Key('registerScreen_emailField');

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
  await pumpUntilFound(tester, _byKey(_emailFieldKey));
}

Future<void> waitForHomeShell(WidgetTester tester) async {
  await pumpUntilFound(
    tester,
    find.byType(NavigationBar),
    timeout: const Duration(seconds: 30),
  );
}

Future<void> enterLoginCredentials(
  WidgetTester tester, {
  String? email,
  String? password,
}) async {
  if (email != null) {
    await tester.enterText(_byKey(_emailFieldKey), email);
  }
  if (password != null) {
    await tester.enterText(_byKey(_passwordFieldKey), password);
  }
}

Future<void> submitLogin(WidgetTester tester) async {
  await tester.ensureVisible(_byKey(_submitButtonKey));
  await tester.tap(_byKey(_submitButtonKey));
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
    // Reset DB về trạng thái seed ban đầu (bao gồm user@e2e.local, admin@e2e.local)
    await resetE2EData();
  });

  // =========================================================================
  // Happy Path
  // =========================================================================
  group('Happy Path', () {
    // TC01 – Đăng nhập thành công với tài khoản hợp lệ
    // Data: user@e2e.local / E2ePass123!
    // Expected: chuyển vào màn hình chính, accessToken được lưu
    testWidgets('[TC01] Đăng nhập thành công với tài khoản hợp lệ', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _seededEmail,
        password: _seededPassword,
      );
      await submitLogin(tester);

      await waitForHomeShell(tester);

      String? accessToken;
      await tester.runAsync(() async {
        accessToken = await sl<SecureStorage>().getAccessToken();
      });
      expect(accessToken, isNotNull);
    });

    // TC02 – Đăng nhập thành công với admin
    // Data: admin@e2e.local / E2ePass123!
    // Expected: đăng nhập thành công với role ADMIN, vào màn hình chính
    testWidgets('[TC02] Đăng nhập thành công với admin', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _adminEmail,
        password: _adminPassword,
      );
      await submitLogin(tester);

      await waitForHomeShell(tester);

      String? accessToken;
      await tester.runAsync(() async {
        accessToken = await sl<SecureStorage>().getAccessToken();
      });
      expect(accessToken, isNotNull);
    });

    // TC03 – Ẩn/hiện mật khẩu không làm thay đổi giá trị
    // Data: user@e2e.local / E2ePass123!
    // Expected: giá trị password giữ nguyên, đăng nhập thành công
    testWidgets('[TC03] Ẩn/hiện mật khẩu không làm thay đổi giá trị', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _seededEmail,
        password: _seededPassword,
      );

      // Mặc định: password bị ẩn (visibility_off)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap để hiện password
      await tester.ensureVisible(find.byIcon(Icons.visibility_off));
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      // Sau khi hiện: icon chuyển sang visibility, text password hiển thị
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.text(_seededPassword), findsOneWidget);

      // Tap để ẩn lại
      await tester.ensureVisible(find.byIcon(Icons.visibility));
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Đăng nhập thành công → giá trị password không thay đổi
      await submitLogin(tester);
      await waitForHomeShell(tester);
    });

    // TC04 – Đăng nhập thành công sau khi nhập sai 1 lần
    // Data: email đúng + password sai lần 1, sau đó đúng lần 2
    // Expected: lần 1 báo lỗi; lần 2 đăng nhập thành công
    testWidgets('[TC04] Đăng nhập thành công sau khi nhập sai 1 lần', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      // Lần 1: sai password → báo lỗi
      await enterLoginCredentials(
        tester,
        email: _seededEmail,
        password: _wrongPassword,
      );
      await submitLogin(tester);

      await pumpUntilFound(tester, find.text(_unauthorizedMessage));

      // Lần 2: đúng password → đăng nhập thành công
      await enterLoginCredentials(
        tester,
        email: _seededEmail,
        password: _seededPassword,
      );
      await submitLogin(tester);

      await waitForHomeShell(tester);
    });
  });

  // =========================================================================
  // Boundary
  // =========================================================================
  group('Boundary', () {
    // TC05 – Email đạt độ dài tối thiểu hợp lệ (6 ký tự): a@b.cd
    // Expected: client validation pass, gửi API; backend 401 (email không tồn tại)
    testWidgets('[TC05] Email đạt độ dài tối thiểu hợp lệ (6 ký tự)', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _minEmail, // a@b.cd
        password: _seededPassword,
      );
      await submitLogin(tester);

      // Client không báo lỗi format → gửi API → backend 401
      await pumpUntilFound(tester, find.text(_unauthorizedMessage));
    });

    // TC06 – Email ngắn hơn tối thiểu 1 ký tự (5 ký tự): a@b.c (TLD 1 ký tự)
    // Expected: client hiển thị lỗi "Email không hợp lệ", không gửi API
    testWidgets('[TC06] Email ngắn hơn tối thiểu 1 ký tự (5 ký tự)', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _minEmailInvalid, // a@b.c
        password: _seededPassword,
      );
      await submitLogin(tester);
      await tester.pump();

      await pumpUntilFound(tester, find.text(_emailInvalidMessage));
    });

    // TC07 – Email đạt độ dài tối đa hợp lệ (255 ký tự)
    // Expected: client validation pass, gửi API; backend 401 (email không tồn tại)
    testWidgets('[TC07] Email đạt độ dài tối đa hợp lệ (255 ký tự)', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _maxEmail,
        password: _seededPassword,
      );
      await submitLogin(tester);

      // Client không báo lỗi format → gửi API → backend 401
      await pumpUntilFound(tester, find.text(_unauthorizedMessage));
    });

    // TC08 – Email vượt độ dài tối đa 1 ký tự (256 ký tự)
    testWidgets('[TC08] Email vượt độ dài tối đa 1 ký tự (256 ký tự)', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _maxEmailInvalid,
        password: _seededPassword,
      );
      await submitLogin(tester);

      // Client không báo lỗi format → gửi API → backend 401
      await pumpUntilFound(tester, find.text(_emailTooLongMessage));
    });

    // TC09 – Password đạt độ dài tối thiểu hợp lệ (6 ký tự): Abc@12
    // Expected: client validation pass, gửi API; backend 401 (password sai)
    testWidgets('[TC09] Password đạt độ dài tối thiểu hợp lệ (6 ký tự)', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _seededEmail,
        password: _minPassword, // Abc@12
      );
      await submitLogin(tester);

      // Client không báo lỗi độ dài → gửi API → backend 401 (password sai)
      await pumpUntilFound(tester, find.text(_unauthorizedMessage));
    });

    // TC10 – Password ngắn hơn tối thiểu 1 ký tự (5 ký tự): Abc@1
    // Expected: client hiển thị lỗi "Mật khẩu phải có ít nhất 6 ký tự"
    testWidgets('[TC10] Password ngắn hơn tối thiểu 1 ký tự (5 ký tự)', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _seededEmail,
        password: _minPasswordInvalid, // Abc@1
      );
      await submitLogin(tester);
      await tester.pump();

      await pumpUntilFound(tester, find.text(_passwordTooShortMessage));
    });

    // TC11 – Password đạt độ dài tối đa hợp lệ (128 ký tự)
    testWidgets('[TC11] Password đạt độ dài tối đa hợp lệ (128 ký tự)', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _seededEmail,
        password: _maxPassword,
      );
      await submitLogin(tester);

      // Client không báo lỗi độ dài → gửi API → backend 401 (password sai)
      await pumpUntilFound(tester, find.text(_unauthorizedMessage));
    });

    // TC12 – Password vượt độ dài tối đa 1 ký tự (129 ký tự)
    testWidgets('[TC12] Password vượt độ dài tối đa 1 ký tự (129 ký tự)', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _seededEmail,
        password: _maxPasswordInvalid,
      );
      await submitLogin(tester);

      await pumpUntilFound(tester, find.text(_passwordTooLongMessage));
    });

    // TC13 – Email có khoảng trắng đầu/cuối (trim test)
    // Data: "  user@e2e.local  " / E2ePass123!
    // Expected: email được trim → đăng nhập thành công
    testWidgets('[TC13] Email có khoảng trắng đầu/cuối (trim test)', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: '  $_seededEmail  ',
        password: _seededPassword,
      );
      await submitLogin(tester);

      await waitForHomeShell(tester);
    });

    // TC14 – Password có khoảng trắng đầu/cuối
    // Data: user@e2e.local / "  E2ePass123!  "
    // Expected: client KHÔNG trim password → backend 401, vẫn ở màn Login
    testWidgets('[TC14] Password có khoảng trắng đầu/cuối', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _seededEmail,
        password: ' $_seededPassword ', // space đầu + cuối
      );
      await submitLogin(tester);

      await pumpUntilFound(tester, find.text(_unauthorizedMessage));
      // Vẫn ở màn Login
      expect(_byKey(_emailFieldKey), findsOneWidget);
    });
  });

  // =========================================================================
  // Negative
  // =========================================================================
  group('Negative', () {
    // TC18 – Bỏ trống email
    // Expected: client hiển thị "Vui lòng nhập email", không gửi API
    testWidgets('[TC18] Bỏ trống email', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(tester, password: _seededPassword);
      await submitLogin(tester);
      await tester.pump();

      expect(find.text(_emailRequiredMessage), findsOneWidget);
      expect(_byKey(_emailFieldKey), findsOneWidget);
    });

    // TC19 – Bỏ trống password
    // Expected: client hiển thị "Vui lòng nhập mật khẩu", không gửi API
    testWidgets('[TC19] Bỏ trống password', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(tester, email: _seededEmail);
      await submitLogin(tester);
      await tester.pump();

      expect(find.text(_passwordRequiredMessage), findsOneWidget);
    });

    // TC20 – Bỏ trống cả email và password
    // Expected: client hiển thị lỗi bắt buộc nhập cho cả 2 trường
    testWidgets('[TC20] Bỏ trống cả email và password', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await submitLogin(tester);
      await tester.pump();

      expect(find.text(_emailRequiredMessage), findsOneWidget);
      expect(find.text(_passwordRequiredMessage), findsOneWidget);
    });

    // TC21 – Định dạng email không hợp lệ (thiếu TLD)
    // Data: user@e2e (thiếu .com, .vn...)
    // Expected: client hiển thị "Email không hợp lệ", không gửi API
    testWidgets('[TC21] Định dạng email không hợp lệ - thiếu TLD', (
      tester,
    ) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: 'user@e2e', // thiếu TLD
        password: _seededPassword,
      );
      await submitLogin(tester);
      await tester.pump();

      expect(find.text(_emailInvalidMessage), findsOneWidget);
    });

    // TC22 – Email không tồn tại trong hệ thống
    // Data: nosuch@e2e.local / E2ePass123!
    // Expected: backend 401 "Unauthorized" (message chung, không tiết lộ email có tồn tại)
    testWidgets('[TC22] Email không tồn tại trong hệ thống', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: 'nosuch@e2e.local',
        password: _seededPassword,
      );
      await submitLogin(tester);

      await pumpUntilFound(tester, find.text(_unauthorizedMessage));
    });

    // TC23 – Sai password cho tài khoản tồn tại
    // Data: user@e2e.local / Wrong#123
    // Expected: backend 401 "Unauthorized"
    testWidgets('[TC23] Sai password cho tài khoản tồn tại', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: _seededEmail,
        password: _wrongPassword,
      );
      await submitLogin(tester);

      await pumpUntilFound(tester, find.text(_unauthorizedMessage));
    });

    // TC24 – Tài khoản chưa kích hoạt (is_active=false)
    // Data: inactive@e2e.local / E2ePass123! (is_active=false trong seed-e2e.sql)
    // Expected: backend trả 401 "Unauthorized" (cùng message với sai credentials),
    //           không vào home, vẫn ở màn Login.
    testWidgets(
      '[TC24] Tài khoản chưa kích hoạt (is_active=false)',
      (tester) async {
        await pumpApp(tester);
        await waitForLoginScreen(tester);

        await enterLoginCredentials(
          tester,
          email: _inactiveEmail,
          password: _seededPassword,
        );
        await submitLogin(tester);

        // Backend từ chối với cùng message generic (không tiết lộ lý do)
        await pumpUntilFound(tester, find.text(_unauthorizedMessage));
        // Vẫn ở màn Login
        expect(_byKey(_emailFieldKey), findsOneWidget);
      },
    );

    // TC25 – Tài khoản bị vô hiệu hóa (banned)
    // Data: disabled@e2e.local / E2ePass123! (ban_reason='E2E test: account disabled' trong seed-e2e.sql)
    // Expected: backend trả 401 "Unauthorized" (cùng message với sai credentials),
    //           không vào home, vẫn ở màn Login.
    testWidgets(
      '[TC25] Tài khoản bị vô hiệu hóa (banned)',
      (tester) async {
        await pumpApp(tester);
        await waitForLoginScreen(tester);

        await enterLoginCredentials(
          tester,
          email: _disabledEmail,
          password: _seededPassword,
        );
        await submitLogin(tester);

        // Backend từ chối với cùng message generic (không tiết lộ lý do bị ban)
        await pumpUntilFound(tester, find.text(_unauthorizedMessage));
        // Vẫn ở màn Login
        expect(_byKey(_emailFieldKey), findsOneWidget);
      },
    );

    // TC26 – Thử SQL Injection trong email
    // Data: ' OR '1'='1 / abc123
    // Expected: client validator bắt lỗi format → không gửi API
    testWidgets('[TC26] Thử SQL Injection trong email', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: "' OR '1'='1",
        password: _seededPassword,
      );
      await submitLogin(tester);
      await tester.pump();

      expect(find.text(_emailInvalidMessage), findsOneWidget);
    });

    // TC27 – Thử XSS trong email
    // Data: <script>alert(1)</script> / abc123
    // Expected: client validator bắt lỗi format → không gửi API, script không thực thi
    testWidgets('[TC27] Thử XSS trong email', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await enterLoginCredentials(
        tester,
        email: '<script>alert(1)</script>',
        password: _seededPassword,
      );
      await submitLogin(tester);
      await tester.pump();

      expect(find.text(_emailInvalidMessage), findsOneWidget);
    });

    // TC28 – Thử brute force nhanh (rate limit / account lock)
    // Backend khoá tài khoản sau maxFailedAttempts=5 lần sai liên tiếp
    // (auth.login.max-failed-attempts=5, trong cùng failure-window 15 phút).
    // HTTP 423 Locked → DioFailureMapper rơi vào _extractMessage()
    // → message = "error.account_locked" (raw error code từ ApiResponse).
    // Expected: lần thứ 6 (hoặc chính xác là lần thứ 5 khi trigger lock)
    //           hiện snackbar "error.account_locked", không vào home.
    testWidgets(
      '[TC28] Thử brute force nhanh (rate limit)',
      (tester) async {
        await pumpApp(tester);
        await waitForLoginScreen(tester);

        // 4 lần sai đầu: backend trả 401 "Unauthorized", chưa lock
        for (var i = 0; i < 4; i++) {
          await enterLoginCredentials(
            tester,
            email: _seededEmail,
            password: _wrongPassword,
          );
          await submitLogin(tester);
          await pumpUntilFound(tester, find.text(_unauthorizedMessage));
        }

        // Lần thứ 5: vượt ngưỡng → backend throw AccountLockedException
        // → HTTP 423 → message "error.account_locked"
        await enterLoginCredentials(
          tester,
          email: _seededEmail,
          password: _wrongPassword,
        );
        await submitLogin(tester);

        await pumpUntilFound(tester, find.text(_accountLockedMessage));
        // Vẫn ở màn Login, không vào home
        expect(_byKey(_emailFieldKey), findsOneWidget);
      },
    );
  });

  // =========================================================================
  // Supporting flows
  // =========================================================================
  group('Supporting flows', () {
    // Token đã tồn tại → chuyển thẳng về home (không qua màn Login)
    testWidgets('Token đã tồn tại thì chuyển thẳng về home', (tester) async {
      await sl<SecureStorage>().saveAccessToken('test-token');

      await pumpApp(tester);
      await waitForHomeShell(tester);

      expect(_byKey(_emailFieldKey), findsNothing);
    });

    // Điều hướng sang quên mật khẩu
    testWidgets('Điều hướng sang quên mật khẩu', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await tester.ensureVisible(_byKey(_forgotPasswordButtonKey));
      await tester.tap(_byKey(_forgotPasswordButtonKey));

      await pumpUntilFound(tester, _byKey(_forgotPasswordEmailFieldKey));
    });

    // Điều hướng sang đăng ký
    testWidgets('Điều hướng sang đăng ký', (tester) async {
      await pumpApp(tester);
      await waitForLoginScreen(tester);

      await tester.ensureVisible(_byKey(_goToRegisterButtonKey));
      await tester.tap(_byKey(_goToRegisterButtonKey));

      await pumpUntilFound(tester, _byKey(_registerEmailFieldKey));
    });
  });
}
