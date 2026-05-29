# Ondas Mobile — Test Cases: Boundary — Display, Rapid Actions, Empty Queue

> **Tính năng**: Hiển thị dữ liệu đặc biệt, rapid actions, empty queue  
> **Phiên bản**: 1.0  
> **Ngày**: 22/05/2026  
> **Loại test**: Functional E2E Test Cases (Integration — automated)  
> **File gốc**: `music_streaming_test_case.md` — TCs: 33-37, 39

---

## Bảng Test Cases

| STT (ID) | Nhóm | Tên Test Case | Các bước thực hiện (Steps) | Dữ liệu kiểm thử (Test Data) | Kết quả mong đợi (Expected Result) |
|---|---|---|---|---|---|
| 25 | Boundary | Tiêu đề bài hát quá dài (nhiều ký tự) | 1) Phát bài hát có title > 100 ký tự<br>2) Quan sát PlayerScreen | Title dài | Tiêu đề hiển thị với ellipsis; không tràn layout; không crash |
| 26 | Boundary | Tên nghệ sĩ có nhiều nghệ sĩ (≥ 5 artists) | 1) Phát bài hát có nhiều nghệ sĩ<br>2) Quan sát hiển thị | Multi-artist song | Hiển thị đúng tiêu đề; không crash |
| 27 | Boundary | Ảnh bìa bài hát = null (không có ảnh) | 1) Phát bài hát có `coverUrl = null`<br>2) Quan sát Player Artwork Widget | Song: coverUrl = null | Hiển thị placeholder / ảnh mặc định; không crash |
| 28 | Boundary | Tua liên tục (rapid seek) nhiều lần trong thời gian ngắn | 1) Phát một bài hát<br>2) Kéo seekbar liên tục 4 lần | Rapid seek | Không crash; seekbar vẫn hoạt động |
| 29 | Boundary | Nhấn Play/Pause liên tục (rapid toggle) | 1) Phát một bài hát<br>2) Nhấn nút Pause/Play liên tục 8 lần | Toggle nhanh | Không crash; nút Play/Pause vẫn hiển thị |
| 30 | Boundary | Queue rỗng (empty queue) khi khởi tạo PlayerState | 1) App mới khởi động, chưa phát bài nào<br>2) Mở route `/player` | queue = []; status = idle | Hiển thị trạng thái idle; icon `music_off`; không crash |

---

> **Tổng số Test Cases:** 6 (tự động hóa trong `integration_test/music_streaming_test.dart`)  
> **Phạm vi:** Long title/artists, null cover, rapid seek/toggle, empty queue
