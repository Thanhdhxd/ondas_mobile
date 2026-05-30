# Ondas Mobile — Test Cases: Boundary — Seek, Volume, Queue cơ bản

> **Tính năng**: Boundary cases cho seek, volume, first/last song, duration, queue size  
> **Phiên bản**: 1.0  
> **Ngày**: 22/05/2026  
> **Loại test**: Functional E2E Test Cases (Integration — automated)  
> **File gốc**: `music_streaming_test_case.md` — TCs: 17-22, 26-27

---

## Bảng Test Cases

| STT (ID) | Nhóm | Tên Test Case | Các bước thực hiện (Steps) | Dữ liệu kiểm thử (Test Data) | Kết quả mong đợi (Expected Result) |
|---|---|---|---|---|---|
| 17 | Boundary | Phát bài hát đầu tiên trong danh sách | 1) Vào danh sách bài hát<br>2) Chạm vào bài hát đầu tiên (index 0) | index = 0; danh sách ≥ 1 bài | Bài hát phát bình thường; nút Previous ở trạng thái disable (không có bài trước) hoặc không phản hồi |
| 18 | Boundary | Phát bài hát cuối cùng trong danh sách | 1) Vào danh sách bài hát<br>2) Chạm vào bài hát cuối cùng (index = n-1) | index = n-1 (bài cuối); danh sách ≥ 1 bài | Bài hát phát bình thường; nút Next ở trạng thái disable hoặc không phản hồi khi chạm (repeat off) |
| 19 | Boundary | Queue chỉ có 1 bài hát — kiểm tra nút Next/Previous | 1) Phát danh sách chỉ có 1 bài<br>2) Nhấn Next<br>3) Nhấn Previous | Queue: [Song A] (chỉ 1 bài) | Nút Next/Previous không gây crash; icon ở trạng thái disabled |
| 20 | Boundary | Bài hát có duration = 0 giây | 1) Phát bài hát có `durationSeconds = 0` | Song: durationSeconds = 0 | Bài hát vẫn load, không crash; thanh seekbar hiển thị 0:00 / 0:00 |
| 21 | Boundary | Bài hát có duration cực dài (≥ 3 giờ) | 1) Phát bài hát dài > 3 giờ<br>2) Quan sát seekbar và hiển thị thời gian | Song: durationSeconds = 10800 (3h) | Hiển thị thời gian đúng định dạng (vd: 3:00:00); seekbar hoạt động bình thường |
| 22 | Boundary | Tua (Seek) về vị trí 0:00 | 1) Phát một bài hát<br>2) Kéo seekbar về 0:00 | Song: bất kỳ; seek to Duration.zero | `position = Duration.zero`; nhạc phát lại từ đầu bài |
| 23 | Boundary | Âm lượng = 0 (Muted) | 1) Phát một bài hát<br>2) Kéo volume về 0<br>3) Quan sát icon và âm thanh | Volume = 0.0 | `PlayerState.volume = 0.0`; icon volume hiển thị trạng thái mute |
| 24 | Boundary | Âm lượng = 1.0 (Tối đa) | 1) Phát một bài hát<br>2) Kéo volume lên tối đa (1.0) | Volume = 1.0 | `PlayerState.volume = 1.0`; icon volume up |

---

> **Tổng số Test Cases:** 8 (tự động hóa trong `integration_test/music_streaming_test.dart`)  
> **Phạm vi:** First/last song, queue size 1, duration (0/3h), seek về 0, volume (0/1)
