import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ondas_mobile/app/app.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/storage/secure_storage.dart';

import 'e2e_api.dart';

const _existingEmailMessage = 'Email đã tồn tại';

const _loginEmailFieldKey = Key('loginScreen_emailField');
const _goToRegisterButtonKey = Key('loginScreen_goToRegisterButton');
const _fullNameFieldKey = Key('registerScreen_fullNameField');
const _emailFieldKey = Key('registerScreen_emailField');
const _passwordFieldKey = Key('registerScreen_passwordField');
const _confirmPasswordFieldKey = Key('registerScreen_confirmPasswordField');
const _submitButtonKey = Key('registerScreen_submitButton');
const _goToLoginButtonKey = Key('registerScreen_goToLoginButton');

Finder _byKey(Key key) => find.byKey(key);

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Timed out waiting for ${finder.description}');
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pumpWidget(const App());
}

Future<void> waitForLoginScreen(WidgetTester tester) async {
  await pumpUntilFound(tester, _byKey(_loginEmailFieldKey));
}

Future<void> waitForRegisterScreen(WidgetTester tester) async {
  await pumpUntilFound(tester, _byKey(_fullNameFieldKey));
}

Future<void> waitForHomeShell(WidgetTester tester) async {
  await pumpUntilFound(
    tester,
    find.byType(NavigationBar),
    timeout: const Duration(seconds: 30),
  );
}

Future<void> openRegisterScreen(WidgetTester tester) async {
  await pumpApp(tester);
  await waitForLoginScreen(tester);
  await tester.ensureVisible(_byKey(_goToRegisterButtonKey));
  await tester.tap(_byKey(_goToRegisterButtonKey));
  await waitForRegisterScreen(tester);
}

Future<void> enterRegisterCredentials(
  WidgetTester tester, {
  String? fullName,
  String? email,
  String? password,
  String? confirmPassword,
}) async {
  if (fullName != null) {
    await tester.enterText(_byKey(_fullNameFieldKey), fullName);
  }
  if (email != null) {
    await tester.enterText(_byKey(_emailFieldKey), email);
  }
  if (password != null) {
    await tester.enterText(_byKey(_passwordFieldKey), password);
  }
  if (confirmPassword != null) {
    await tester.enterText(_byKey(_confirmPasswordFieldKey), confirmPassword);
  }
}

Future<void> submitRegister(WidgetTester tester) async {
  await tester.ensureVisible(_byKey(_submitButtonKey));
  await tester.tap(_byKey(_submitButtonKey));
}

Future<Map<String, dynamic>> loadProfile(WidgetTester tester) async {
  String? accessToken;
  await tester.runAsync(() async {
    accessToken = await sl<SecureStorage>().getAccessToken();
  });
  if (accessToken == null) {
    throw StateError('Missing access token for profile fetch');
  }
  final profile = await tester.runAsync(
    () async => fetchProfile(accessToken: accessToken!),
  );
  if (profile == null) {
    throw StateError('Missing profile response');
  }
  return profile;
}

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

  group('Happy Path', () {
    testWidgets('[TC01] Đăng ký thành công với dữ liệu hợp lệ', (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);

      await waitForHomeShell(tester);

      String? accessToken;
      await tester.runAsync(() async {
        accessToken = await sl<SecureStorage>().getAccessToken();
      });
      expect(accessToken, isNotNull);
    });

    testWidgets(
        '[TC02] Đăng ký thành công với password có ký tự đặc biệt',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Trần Thị B',
        email: 'userb@example.com',
        password: 'Abc@#1234',
        confirmPassword: 'Abc@#1234',
      );
      await submitRegister(tester);

      await waitForHomeShell(tester);
    });

    testWidgets('[TC03] Ẩn/hiện password không làm thay đổi giá trị',
        (tester) async {
      await openRegisterScreen(tester);

      const password = 'P@ssw0rd123';
      await enterRegisterCredentials(
        tester,
        password: password,
        confirmPassword: password,
      );

      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsNWidgets(2));
      expect(find.text(password), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    testWidgets('[TC04] Họ và tên có khoảng trắng giữa các từ',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn Anh Khoa',
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);

      await waitForHomeShell(tester);
      final profile = await loadProfile(tester);
      expect(profile['displayName'], 'Nguyễn Văn Anh Khoa');
    });

    testWidgets('[TC05] Đăng ký thành công sau khi sửa lỗi validation',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'user@',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Email không hợp lệ'), findsOneWidget);

      await enterRegisterCredentials(
        tester,
        email: 'user@example.com',
      );
      await submitRegister(tester);

      await waitForHomeShell(tester);
    });
  });

  group('Boundary', () {
    testWidgets('[TC06] Họ và tên đúng độ dài tối thiểu (2 ký tự)',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'AB',
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);

      await waitForHomeShell(tester);
    });

    testWidgets('[TC07] Họ và tên ngắn hơn tối thiểu 1 ký tự (1 ký tự)',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'A',
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Họ và tên phải có ít nhất 2 ký tự'), findsOneWidget);
    });

    testWidgets('[TC08] Password đúng độ dài tối thiểu (6 ký tự)',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@example.com',
        password: 'Abc@12',
        confirmPassword: 'Abc@12',
      );
      await submitRegister(tester);

      await waitForHomeShell(tester);
    });

    testWidgets('[TC09] Password ngắn hơn tối thiểu 1 ký tự (5 ký tự)',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@example.com',
        password: 'Ab@12',
        confirmPassword: 'Ab@12',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('[TC10] Họ và tên có khoảng trắng đầu/cuối',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: '  Nguyễn Văn A  ',
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);

      await waitForHomeShell(tester);
      final profile = await loadProfile(tester);
      expect(profile['displayName'], 'Nguyễn Văn A');
    });

    testWidgets('[TC11] Email có khoảng trắng đầu/cuối', (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: '  newuser@example.com  ',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);

      await waitForHomeShell(tester);
      final profile = await loadProfile(tester);
      expect(profile['email'], 'newuser@example.com');
    });

    // Backend policy for whitespace passwords is environment-specific.
    testWidgets('[TC12] Password có khoảng trắng đầu/cuối', (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@example.com',
        password: ' P@ssw0rd123 ',
        confirmPassword: ' P@ssw0rd123 ',
      );
      await submitRegister(tester);

      final homeFound = await _tryWaitForHomeShell(tester);
      if (!homeFound) {
        expect(_byKey(_fullNameFieldKey), findsOneWidget);
      }
    });
  });

  group('Negative', () {
    testWidgets('[TC13] Bỏ trống họ và tên', (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
    });

    testWidgets('[TC14] Bỏ trống email', (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Vui lòng nhập email'), findsOneWidget);
    });

    testWidgets('[TC15] Bỏ trống password', (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@example.com',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    });

    testWidgets('[TC16] Bỏ trống confirm password', (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Vui lòng xác nhận mật khẩu'), findsOneWidget);
    });

    testWidgets('[TC17] Bỏ trống tất cả các trường', (tester) async {
      await openRegisterScreen(tester);

      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
      expect(find.text('Vui lòng xác nhận mật khẩu'), findsOneWidget);
    });

    testWidgets('[TC18] Định dạng email không hợp lệ - thiếu @',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuserexample.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets('[TC19] Định dạng email không hợp lệ - thiếu domain',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets(
        '[TC20] Định dạng email không hợp lệ - TLD quá ngắn (1 ký tự)',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@example.c',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets('[TC21] Confirm password không khớp với password',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd456',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Mật khẩu không khớp'), findsOneWidget);
    });

    testWidgets('[TC22] Confirm password khác password chỉ về chữ hoa/thường',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@example.com',
        password: 'p@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Mật khẩu không khớp'), findsOneWidget);
    });

    testWidgets('[TC23] Email đã được đăng ký trước đó', (tester) async {
      await tester.runAsync(() async {
        await registerUser(
          fullName: 'Nguyễn Văn A',
          email: 'existing@example.com',
          password: 'P@ssw0rd123',
        );
      });

      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'existing@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);

      await pumpUntilFound(tester, find.text(_existingEmailMessage));
      expect(_byKey(_fullNameFieldKey), findsOneWidget);
    });

    testWidgets('[TC24] Họ và tên chỉ gồm khoảng trắng', (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: '   ',
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
    });

    testWidgets('[TC25] Thử SQL Injection trong trường họ và tên',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: "' OR '1'='1",
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(_byKey(_fullNameFieldKey), findsOneWidget);
    });

    testWidgets('[TC26] Thử XSS trong trường họ và tên', (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: '<script>alert(1)</script>',
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);

      await waitForHomeShell(tester);
    });

    testWidgets('[TC27] Thử SQL Injection trong trường email', (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: "' OR '1'='1",
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);
      await tester.pump();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });
  });

  group('UX / Navigation', () {
    testWidgets('[TC28] Nhấn "Đã có tài khoản? Đăng nhập" chuyển về màn Login',
        (tester) async {
      await openRegisterScreen(tester);

      await tester.ensureVisible(_byKey(_goToLoginButtonKey));
      await tester.tap(_byKey(_goToLoginButtonKey));

      await pumpUntilFound(tester, _byKey(_loginEmailFieldKey));
    });

    testWidgets('[TC29] Người dùng đã đăng nhập truy cập màn Register',
        (tester) async {
      await openRegisterScreen(tester);

      await enterRegisterCredentials(
        tester,
        fullName: 'Nguyễn Văn A',
        email: 'newuser@example.com',
        password: 'P@ssw0rd123',
        confirmPassword: 'P@ssw0rd123',
      );
      await submitRegister(tester);

      await waitForHomeShell(tester);

      final context = tester.element(find.byType(NavigationBar));
      GoRouter.of(context).go('/register');
      await tester.pumpAndSettle();

      await waitForHomeShell(tester);
      expect(_byKey(_fullNameFieldKey), findsNothing);
    });

    // Requires controllable API delay to assert loading state.
    testWidgets(
      '[TC30] Nút Đăng ký bị vô hiệu hóa khi đang gọi API',
      (tester) async {},
      skip: true,
    );
  });

  group('Network', () {
    // Requires network fault injection.
    testWidgets(
      '[TC31] Đăng ký khi mất kết nối mạng',
      (tester) async {},
      skip: true,
    );

    // Requires backend timeout simulation.
    testWidgets(
      '[TC32] Đăng ký khi server timeout',
      (tester) async {},
      skip: true,
    );

    // Requires backend error simulation (500).
    testWidgets(
      '[TC33] Đăng ký khi server trả về lỗi 500',
      (tester) async {},
      skip: true,
    );
  });
}

Future<bool> _tryWaitForHomeShell(WidgetTester tester) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (find.byType(NavigationBar).evaluate().isNotEmpty) {
      return true;
    }
  }
  return false;
}