# Project Instructions — Ondas Mobile App (Flutter)

> **Phạm vi áp dụng**: Repo `ondas_mobile` — Mobile App dành cho Android / iOS
> **Stack**: Flutter 3.x + Dart 3.x | State: BLoC | DI: GetIt | Nav: go_router | HTTP: Dio

---

## 1. TỔNG QUAN DỰ ÁN

Ondas Mobile là ứng dụng nghe nhạc trực tuyến cho Android / iOS. Entry point duy nhất: `lib/main.dart`.

Backend giao tiếp qua REST API (Spring Boot). Mọi request đều đi qua `DioClient` với `JwtInterceptor`.

---

## 2. CẤU TRÚC THƯ MỤC — BẮT BUỘC TUÂN THỦ

```
lib/
├── core/                          # Code dùng chung toàn project
│   ├── constants/
│   │   ├── api_constants.dart     # Base URL, endpoint paths
│   │   └── app_constants.dart     # App-wide constants
│   ├── di/
│   │   └── injection.dart         # GetIt setup — khởi tạo 1 lần
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── dio_client.dart        # Dio HTTP client
│   │   ├── jwt_interceptor.dart   # JWT attach + auto refresh
│   │   └── api_response.dart      # Generic response wrapper
│   ├── storage/
│   │   └── secure_storage.dart    # FlutterSecureStorage
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   └── utils/
│       ├── date_formatter.dart
│       └── validators.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── player/                    # Background playback, notification control
│   ├── library/                   # Danh sách bài hát / nghệ sĩ / album / thể loại
│   ├── search/                    # Tìm kiếm
│   ├── playlist/                  # Playlist cá nhân + yêu thích
│   ├── lyrics/                    # Lyrics tĩnh + Synced Lyrics
│   └── profile/                   # Profile người dùng, lịch sử nghe
│
├── app/
│   ├── app.dart
│   └── router/
│       └── app_router.dart
│
└── main.dart                      # Entry point duy nhất
```

---

## 3. NGUYÊN TẮC PHÂN TẦNG CODE (QUAN TRỌNG NHẤT)

### 3.1 Clean Architecture trong mỗi feature

Mỗi feature phải tuân theo đúng 3 tầng:

```
features/<tên_feature>/
├── data/          # datasource, model, repository_impl
├── domain/        # entity, repository interface, usecase interface + impl
└── presentation/  # bloc, screens, widgets
```

- **domain/** không được import bất kỳ package Flutter hay Dio nào — chỉ thuần Dart.
- **data/** implements interface ở domain, gọi API qua DioClient.
- **presentation/** dùng BLoC để quản lý state, không gọi trực tiếp repository.
- Mỗi UseCase **bắt buộc** có 2 file: interface (`*_usecase.dart`) và implementation (`*_usecase_impl.dart`).

### 3.2 Quy tắc import package audio

Package `just_audio` và `audio_service` **CHỈ được import** trong `features/player/`.  
**Không được import** vào bất kỳ file nào khác trong project.

---

## 4. NAMING CONVENTION

### 4.1 File và thư mục

| Loại                | Convention         | Ví dụ                          |
|---------------------|--------------------|-------------------------------|
| Thư mục             | `snake_case`       | `auth/`, `player/`            |
| File Dart           | `snake_case.dart`  | `song_bloc.dart`              |

### 4.2 Class

| Loại                    | Convention               | Ví dụ                              |
|-------------------------|--------------------------|------------------------------------|
| Entity (domain)         | `PascalCase`             | `Song`, `User`, `Playlist`         |
| Model (data)            | `PascalCase + Model`     | `SongModel`, `UserModel`           |
| Repository interface    | `PascalCase + Repository`| `AuthRepository`                   |
| Repository impl         | `...RepositoryImpl`      | `AuthRepositoryImpl`               |
| UseCase **interface**   | `VerbNounUseCase`        | `LoginUseCase`, `GetSongsUseCase`  |
| UseCase **impl**        | `...UseCaseImpl`         | `LoginUseCaseImpl`                 |
| BLoC                    | `PascalCase + Bloc`      | `PlayerBloc`, `SongBloc`           |
| Event                   | `PascalCase + Event`     | `PlayerEvent`, `PlaySongEvent`     |
| State                   | `PascalCase + State`     | `PlayerState`, `PlayerLoaded`      |
| Screen                  | `PascalCase + Screen`    | `LoginScreen`, `HomeScreen`        |
| Widget                  | `PascalCase + Widget`    | `SongCardWidget`                   |

### 4.3 Route path

Pattern: `/camelCase` — Ví dụ: `/home`, `/player`, `/search`, `/library`

---

## 5. DEPENDENCY INJECTION (GetIt)

- Tất cả registration **chỉ được thực hiện một lần** tại `lib/core/di/injection.dart`.
- Hàm `setupDependencies()` được gọi từ `main.dart`.
- **Không được** khởi tạo dependency trực tiếp trong Widget hay BLoC — luôn dùng `sl<T>()`.
- Thứ tự đăng ký: Storage → Network → Repositories → UseCases → BLoCs.

```dart
// ✅ ĐÚNG
final authBloc = sl<AuthBloc>();

// ❌ SAI
final authBloc = AuthBloc(repository: AuthRepositoryImpl(...));
```

---

## 6. STATE MANAGEMENT (BLoC)

- **Mọi screen** phải dùng BLoC để quản lý state — không dùng `setState` ngoài widget thuần UI đơn giản.
- BLoC **không được** import trực tiếp package Dio hay gọi API — chỉ gọi qua UseCase.
- Event và State phải dùng `Equatable` hoặc `freezed`.
- Đặt BLoC, Event, State trong `presentation/bloc/` của feature tương ứng.

```
features/auth/presentation/
├── bloc/
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   └── auth_state.dart
├── screens/
│   └── login_screen.dart
└── widgets/
```

---

## 7. USECASE PATTERN — BẮT BUỘC CÓ INTERFACE VÀ IMPLEMENTATION

Mỗi UseCase **bắt buộc** tách thành 2 file riêng biệt trong `domain/usecases/`:

```
features/auth/domain/usecases/
├── login_usecase.dart          # Interface (abstract class)
└── login_usecase_impl.dart     # Implementation
```

### 7.1 Interface UseCase

```dart
// domain/usecases/login_usecase.dart
abstract class LoginUseCase {
  Future<Either<Failure, User>> call(LoginParams params);
}

class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}
```

### 7.2 Implementation UseCase

```dart
// domain/usecases/login_usecase_impl.dart
class LoginUseCaseImpl implements LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return _repository.login(email: params.email, password: params.password);
  }
}
```

### 7.3 Đăng ký trong GetIt

```dart
sl.registerLazySingleton<LoginUseCase>(
  () => LoginUseCaseImpl(sl<AuthRepository>()),
);
```

> BLoC inject `LoginUseCase` (interface) — **không inject** `LoginUseCaseImpl` trực tiếp.

---

## 8. QUY TẮC KIỂM THỬ — BẮT BUỘC SAU MỖI CHỨC NĂNG / MÀN HÌNH

> ⚠️ **Không được merge** branch feature vào `dev` nếu chưa có đủ test cho chức năng/màn hình đó.

### 8.1 Vị trí đặt test

```
test/
├── unit/
│   └── features/
│       ├── auth/
│       │   ├── usecases/
│       │   │   └── login_usecase_test.dart
│       │   └── bloc/
│       │       └── auth_bloc_test.dart
│       └── player/
│           └── usecases/
│               └── play_song_usecase_test.dart
└── widget/
    └── features/
        ├── auth/
        │   └── login_screen_test.dart
        └── player/
            └── player_screen_test.dart
```

### 8.2 Yêu cầu Unit Test

**Phải có unit test cho:**
- Mọi `UseCase` (test qua interface, mock Repository)
- Mọi `BLoC` (test events → states, dùng `bloc_test`)
- Các utility function trong `core/utils/`

**Template Unit Test cho UseCase:**

```dart
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCaseImpl(mockRepository);
  });

  group('LoginUseCase', () {
    test('should return User when login succeeds', () async {
      when(() => mockRepository.login(email: any, password: any))
          .thenAnswer((_) async => Right(tUser));
      final result = await useCase(LoginParams(email: 'a@b.com', password: '123'));
      expect(result, Right(tUser));
    });

    test('should return Failure when credentials are invalid', () async {
      when(() => mockRepository.login(email: any, password: any))
          .thenAnswer((_) async => Left(UnauthorizedFailure()));
      final result = await useCase(LoginParams(email: 'a@b.com', password: 'wrong'));
      expect(result, Left(UnauthorizedFailure()));
    });
  });
}
```

**Template Unit Test cho BLoC:**

```dart
void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    bloc = AuthBloc(loginUseCase: mockLoginUseCase);
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthSuccess] when login succeeds',
    build: () {
      when(() => mockLoginUseCase(any())).thenAnswer((_) async => Right(tUser));
      return bloc;
    },
    act: (b) => b.add(LoginSubmitted(email: 'a@b.com', password: '123')),
    expect: () => [AuthLoading(), AuthSuccess(user: tUser)],
  );
}
```

### 8.3 Yêu cầu Widget Test

**Phải có widget test cho mỗi màn hình (Screen):**
- Test render UI thành công (không crash)
- Test hiển thị loading state khi BLoC emit `Loading`
- Test hiển thị error message khi BLoC emit `Error`
- Test interaction: tap button → đúng Event được add vào BLoC

**Template Widget Test cho Screen:**

```dart
void main() {
  late MockAuthBloc mockBloc;

  setUp(() {
    mockBloc = MockAuthBloc();
  });

  Widget buildSubject() => MaterialApp(
    home: BlocProvider<AuthBloc>.value(
      value: mockBloc,
      child: const LoginScreen(),
    ),
  );

  testWidgets('renders email and password fields', (tester) async {
    when(() => mockBloc.state).thenReturn(AuthInitial());
    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('loginScreen_emailField')), findsOneWidget);
    expect(find.byKey(const Key('loginScreen_passwordField')), findsOneWidget);
    expect(find.byKey(const Key('loginScreen_submitButton')), findsOneWidget);
  });
}
```

### 8.4 Quy tắc đặt Key cho Widget

Mọi interactive element trong Screen **phải có** `Key`:

```dart
// ✅ ĐÚNG
TextField(key: const Key('loginScreen_emailField'), ...)
ElevatedButton(key: const Key('loginScreen_submitButton'), ...)
```

Format: `'<screenName>_<elementName>'` (camelCase)

### 8.5 Công cụ và package test

| Package       | Dùng cho                                |
|---------------|-----------------------------------------|
| `flutter_test`| Widget test, tích hợp sẵn Flutter SDK  |
| `bloc_test`   | Unit test BLoC (events → states)        |
| `mocktail`    | Mock repository, usecase trong test     |

### 8.6 Chạy test

```bash
flutter test
flutter test test/unit/features/auth/usecases/login_usecase_test.dart
flutter test --coverage
```

---

## 9. NETWORKING

- **Mọi HTTP request** phải đi qua `DioClient` — không được tạo instance `Dio` mới ở nơi khác.
- Token JWT được gắn tự động bởi `JwtInterceptor` — không thêm header Authorization thủ công.
- Response API phải được wrap qua `ApiResponse<T>` trước khi trả về Domain layer.
- Xử lý lỗi mạng tập trung ở Repository implementation, không để lọt lên BLoC dạng raw exception.

---

## 10. NAVIGATION (go_router)

- Router định nghĩa tại `lib/app/router/app_router.dart`.
- **Không được** dùng `Navigator.push()` trực tiếp — luôn dùng `context.go()` hoặc `context.push()`.
- Router phải có redirect guard kiểm tra token trước khi vào các route cần đăng nhập.

---

## 11. BUILD & RUN COMMANDS

```bash
# Chạy app
flutter run

# Build APK release
flutter build apk --release

# Build AAB release
flutter build appbundle --release

# Chạy toàn bộ test
flutter test
```

---

## 12. GIT WORKFLOW

### Branch strategy

```
main          ← Production release
└── dev       ← Integration (merge cuối mỗi tuần)
    ├── feature/trieu-<tên-task>
    ├── feature/thanh-<tên-task>
    └── feature/bac-<tên-task>
```

### Commit message format

```
feat(mobile): <mô tả>
feat(auth): <mô tả>
feat(player): <mô tả>
fix(mobile): <mô tả>
test(auth): <mô tả>
refactor(player): <mô tả>
```

---

## 13. QUY TẮC VIẾT CODE

1. **Không hardcode** Base URL hay API path — đặt trong `core/constants/api_constants.dart`.
2. **Không dùng** `print()` trong production code.
3. **Mọi string UI** đặt thành constant (sẵn sàng cho i18n sau).
4. Widget screen phải **tách nhỏ** thành các widget con — 1 file < 300 dòng.
5. Mỗi UseCase chỉ xử lý **1 business action duy nhất**.
6. **Phân định rõ `StatelessWidget` và `StatefulWidget`**:
   - Ưu tiên `StatelessWidget` cho widget hiển thị thuần.
   - Chỉ dùng `StatefulWidget` cho local UI state ngắn hạn (`TextEditingController`, `FocusNode`, `AnimationController`...).
   - Business state (loading/data/error, auth, player state...) phải đi qua BLoC.

### 13.1 Ngưỡng tách widget con

| Dấu hiệu | Ngưỡng | Hành động |
|---|---|---|
| Số dòng trong `build()` | > 60 dòng | Tách thành widget con |
| Số tham số truyền vào widget | > 4 tham số | Gom vào object hoặc đưa lên BLoC |
| Số nhánh `if/else` / `switch` trong `build()` | ≥ 3 nhánh | Tách thành widget riêng |
| Số callback truyền xuống widget con | > 2 callback | Đưa logic lên BLoC event |

```dart
// ✅ ĐÚNG — tách theo khối giao diện
class SongDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongBloc, SongState>(
      builder: (context, state) => switch (state) {
        SongLoading() => const _LoadingView(),
        SongError(:final message) => _ErrorView(message: message),
        SongLoaded(:final song) => _ContentView(song: song),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
```

---

## 14. QUY TẮC UI / THEME (GIAO DIỆN)

1. **Màu sắc** khai báo tại `core/theme/app_colors.dart`. Không hardcode `Color(0xFF...)` trong UI.
2. Hỗ trợ cả **Light Mode** và **Dark Mode** với `ThemeData` đầy đủ tại `core/theme/app_theme.dart`.
3. **Spacing & Radius**: dùng hằng số chuẩn (`AppSpacing.sm`, `AppRadius.md`...).
4. **Typography**: dùng `Theme.of(context).textTheme.*`, không tạo `TextStyle` tuỳ tiện.
5. **Semantic Colors**: định nghĩa đầy đủ `success`, `warning`, `error`, `info` cho cả 2 mode.
6. **Component Theme**: cấu hình tập trung cho `ElevatedButton`, `InputDecoration`, `Card`, `AppBar`, `SnackBar`, `NavigationBar`.
7. **Tuân thủ Material Design 3** làm baseline.

### Cấu trúc file theme

```
lib/core/theme/
├── app_colors.dart
├── app_semantic_colors.dart
├── app_spacing.dart
├── app_radius.dart
├── app_typography.dart
├── app_elevation.dart
├── app_motion.dart
├── app_theme_extensions.dart
└── app_theme.dart
```

---

## 15. CHECKLIST TRƯỚC KHI COMMIT

### Kiến trúc & Code
- [ ] Code đặt đúng thư mục theo phân tầng (`core/`, `features/`, `app/`)
- [ ] `just_audio`/`audio_service` chỉ import trong `features/player/`
- [ ] BLoC không gọi API trực tiếp — chỉ qua UseCase
- [ ] Không dùng `Navigator.push()` — dùng `context.go()`
- [ ] Mỗi UseCase có đủ 2 file: `*_usecase.dart` (interface) + `*_usecase_impl.dart` (implementation)
- [ ] BLoC inject interface UseCase, không inject impl trực tiếp
- [ ] Screen tách thành widget nhỏ; phân định rõ `StatelessWidget` và `StatefulWidget`

### Kiểm thử
- [ ] Có **unit test cho UseCase** — test cả happy path lẫn error/edge case
- [ ] Có **unit test cho BLoC** — test events → states bằng `blocTest`
- [ ] Có **widget test cho Screen** — test render, loading, error, interaction
- [ ] Mọi interactive element có `Key` theo format `'<screenName>_<elementName>'`
- [ ] `flutter test` pass **100%, không có lỗi**

### UI / Theme
- [ ] Không hardcode màu, spacing, radius, typography trong UI
- [ ] Tuân thủ Material Design 3
- [ ] Cả Light/Dark có đủ `ColorScheme` + semantic colors
- [ ] Component theme cấu hình tập trung

### Build
- [ ] `flutter build apk --release` thành công
- [ ] Commit message theo đúng format `feat(scope): ...`
