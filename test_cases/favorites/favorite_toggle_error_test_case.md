# Ondas Mobile — Test Cases: Nút Yêu thích — Xử lý lỗi & Bảo mật

> **Tính năng**: Xử lý lỗi khi toggle nút yêu thích (offline, server error, JWT, security)  
> **Phiên bản**: 1.0  
> **Ngày**: 22/05/2026  
> **Loại test**: Functional E2E Test Cases (Manual / Exploratory)  
> **File gốc**: `favorites_test_case.md` — TCs: 26-27, 31-32, 36, 38-45, 47, 49, 53

---

## Thành phần liên quan

| Thành phần | Mô tả |
|---|---|
| `FavoriteButtonWidget` | Nút trái tim độc lập — mỗi nút tự tạo `FavoriteToggleBloc` riêng |
| `FavoriteToggleBloc` | Quản lý toggle thêm/xóa — optimistic update + revert khi fail |
| Các UseCase | `AddFavoriteUseCase`, `RemoveFavoriteUseCase`, `CheckFavoriteStatusUseCase` |

---

## Bảng Test Cases

| STT (ID) | Nhóm | Tên Test Case | Các bước thực hiện (Steps) | Dữ liệu kiểm thử (Test Data) | Kết quả mong đợi (Expected Result) |
|---|---|---|---|---|---|
| 26 | Negative | Thêm bài hát vào yêu thích khi mất kết nối mạng | 1) Tắt kết nối mạng<br>2) Nhấn nút trái tim (unchecked → checked)<br>3) Quan sát | Song: id="song_offline"; không có mạng | Optimistic update: icon chuyển sang checked (đỏ) → API fail → `FavoriteToggleError` emit → revert về unchecked (trắng); hiển thị SnackBar lỗi (message từ `e.toString()`); không crash |
| 27 | Negative | Xóa bài hát khỏi yêu thích khi mất kết nối mạng | 1) Tắt kết nối mạng<br>2) Nhấn nút trái tim (checked → unchecked)<br>3) Quan sát | Song: id="song_offline2"; đang checked; không có mạng | Optimistic update: icon chuyển sang unchecked (trắng) → API fail → `FavoriteToggleError` emit → revert về checked (đỏ); hiển thị SnackBar lỗi; không crash |
| 31 | Negative | Server trả về lỗi 500 khi thêm bài hát vào yêu thích | 1) Giả lập server lỗi 500<br>2) Nhấn nút trái tim để thêm yêu thích<br>3) Quan sát | Server 500 Internal Server Error | Optimistic: icon chuyển checked → API fail 500 → revert về unchecked; hiển thị `FavoriteToggleError` → SnackBar lỗi; không crash |
| 32 | Negative | Server trả về lỗi 500 khi xóa bài hát khỏi yêu thích | 1) Giả lập server lỗi 500<br>2) Nhấn nút trái tim để xóa yêu thích<br>3) Quan sát | Server 500 | Optimistic: icon chuyển unchecked → API fail 500 → revert về checked; SnackBar lỗi; không crash |
| 36 | Negative | Server timeout khi toggle yêu thích | 1) Giả lập server timeout<br>2) Nhấn nút trái tim để thêm yêu thích<br>3) Quan sát | Server timeout | Optimistic update → API timeout → revert trạng thái cũ; SnackBar lỗi hiển thị; không crash |
| 38 | Negative | JWT token hết hạn khi thêm bài hát vào yêu thích | 1) JWT token hết hạn<br>2) Nhấn nút trái tim để thêm yêu thích<br>3) Quan sát | Token expired | JWT interceptor refresh token → nếu thành công: thêm thành công; nếu thất bại: revert + redirect về Login |
| 39 | Negative | JWT token hết hạn khi xóa bài hát khỏi yêu thích | 1) JWT token hết hạn<br>2) Nhấn nút trái tim để xóa yêu thích<br>3) Quan sát | Token expired | Tương tự trên: auto-refresh hoặc redirect về Login; optimistic update revert nếu refresh thất bại |
| 40 | Negative | Server trả về 403 Forbidden khi thêm yêu thích (không có quyền) | 1) Gửi request thêm yêu thích với token không có quyền<br>2) Quan sát | 403 Forbidden | Optimistic revert; hiển thị SnackBar lỗi với message phù hợp; không crash |
| 41 | Negative | Server trả về 404 khi thêm yêu thích cho bài hát không tồn tại | 1) Nhấn nút trái tim với songId không tồn tại trên server<br>2) Quan sát | songId: "song_nonexistent" | Server trả về 404; optimistic revert; hiển thị SnackBar lỗi; không crash |
| 42 | Negative | Server trả về 404 khi xóa yêu thích cho bài hát không có trong danh sách | 1) Gửi request xóa yêu thích với songId chưa từng được thêm<br>2) Quan sát | songId: "song_not_favorited" | Server trả về 404 (không tìm thấy để xóa); optimistic revert; hiển thị lỗi; không crash |
| 43 | Negative | Server trả về 409 Conflict khi thêm bài hát đã có trong yêu thích | 1) Bài hát đã được yêu thích (checked)<br>2) Gửi lại request addFavorite (race condition hoặc lỗi state)<br>3) Quan sát | Song đã có trong favorites; gửi thêm lần nữa | Server trả về 409; optimistic revert về checked (vì thực tế bài hát vẫn đang được yêu thích); SnackBar thông báo "Bài hát đã có trong danh sách yêu thích"; không crash |
| 44 | Negative | Thử SQL Injection trong songId khi toggle yêu thích | 1) Gửi request addFavorite với songId = `'; DROP TABLE favorites; --`<br>2) Quan sát | songId: "'; DROP TABLE favorites; --" | Input được xử lý an toàn (parameterized query); server trả về lỗi validation 400 hoặc không tìm thấy bài hát; không có SQL được thực thi; ứng dụng không crash |
| 45 | Negative | Thử XSS trong tiêu đề bài hát hiển thị trong danh sách yêu thích | 1) Thêm bài hát có title chứa script tag vào favorites<br>2) Vào FavoritesScreen<br>3) Quan sát hiển thị | Title: "&lt;script&gt;alert('xss')&lt;/script&gt;" | Tiêu đề hiển thị dưới dạng text thuần; script không được thực thi; không có alert popup |
| 47 | Negative | Ứng dụng bị kill khi đang thực hiện toggle yêu thích | 1) Nhấn nút trái tim để thêm yêu thích<br>2) Force kill app ngay sau khi nhấn (trước khi API trả về)<br>3) Mở lại app, kiểm tra trạng thái | Song: id="song_kill"; đang gọi API addFavorite; force kill | App khởi động lại bình thường; trạng thái yêu thích tùy thuộc vào API đã hoàn thành trên server hay chưa; khi mở lại, `FavoriteButtonWidget` gọi `checkFavoriteStatus` → hiển thị đúng trạng thái server; không crash, không corrupt data |
| 49 | Negative | Nhấn nút trái tim khi FavoriteToggleBloc đang ở trạng thái loading | 1) Mở màn hình có FavoriteButtonWidget<br>2) Khi API check status đang loading (hiển thị CircularProgressIndicator)<br>3) Thử nhấn vào nút<br>4) Quan sát | Đang loading | Nút bị disable (`onPressed: null` khi `isLoading = true`); không thể nhấn; không gửi duplicate request; không crash |
| 53 | Negative | API checkFavoriteStatus trả về lỗi — fallback về false | 1) FavoriteButtonWidget mount<br>2) API `checkFavoriteStatus` trả về lỗi (network error, 500...)<br>3) Quan sát | API check status lỗi | `FavoriteToggleBloc._onStatusCheckRequested` catch lỗi → emit `FavoriteToggleLoaded(isFavorited: false)`; icon hiển thị unchecked (trắng) — an toàn, không hiển thị sai trạng thái checked; không crash |

---

> **Tổng số Test Cases:** 16  
> **Phân bố:** Negative: 16  
> **Phạm vi:** Offline, Server errors (500/403/404/409), JWT expired, timeout, security (SQL Injection, XSS), app lifecycle, loading state
