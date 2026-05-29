# Ondas Mobile — Test Cases: Phát nhạc (Player Playback)

> **Tính năng**: Phát/tạm dừng, chuyển bài, tua, âm lượng, repeat, mini player, queue, lyrics, play history  
> **Phiên bản**: 1.0  
> **Ngày**: 22/05/2026  
> **Loại test**: Functional E2E Test Cases (Integration — automated)  
> **File gốc**: `music_streaming_test_case.md` — TCs: 01-16

---

## Thành phần liên quan

| Thành phần | Mô tả |
|---|---|
| `PlayerScreen` | Màn hình phát nhạc đầy đủ — controls, seekbar, artwork, tabs (Queue/Lyrics) |
| `MiniPlayer` | Mini player hiển thị ở bottom khi rời PlayerScreen |
| `PlayerBloc` | Quản lý state phát nhạc — `PlaySongRequested`, `PauseRequested`, `ResumeRequested`, etc. |

---

## Bảng Test Cases

| STT (ID) | Nhóm | Tên Test Case | Các bước thực hiện (Steps) | Dữ liệu kiểm thử (Test Data) | Kết quả mong đợi (Expected Result) |
|---|---|---|---|---|---|
| 01 | Happy Path | Phát một bài hát từ danh sách bài hát (SongListScreen) | 1) Mở màn danh sách bài hát của Artist<br>2) Chạm vào một bài hát<br>3) Quan sát Player | Song hợp lệ có `audioUrl` | PlayerScreen mở ra; artwork hiển thị |
| 02 | Happy Path | Phát một bài hát từ kết quả tìm kiếm | 1) Vào Search<br>2) Tìm kiếm<br>3) Chạm bài hát<br>4) Quan sát Player | Keyword: "E2E Track One" | PlayerScreen mở ra |
| 03 | Happy Path | Phát một bài hát từ danh sách yêu thích | 1) Vào Favorites<br>2) Chạm bài hát yêu thích | Song trong favorites | PlayerScreen mở ra |
| 04 | Happy Path | Phát một bài hát từ Playlist Detail | 1) Mở Playlist<br>2) Chạm bài hát | Playlist E2E | PlayerScreen mở ra |
| 05 | Happy Path | Tạm dừng (Pause) và tiếp tục (Resume) | 1) Phát bài<br>2) Pause<br>3) Resume | Bài đang playing | Icon đổi Play/Pause đúng |
| 06 | Happy Path | Chuyển bài tiếp theo (Skip Next) | 1) Phát queue<br>2) Nhấn Next | Queue nhiều bài | Không crash; controls hoạt động |
| 07 | Happy Path | Skip Previous — bài đã phát > 3 giây | 1) Phát bài thứ 2<br>2) Seek > 3s<br>3) Previous | Queue playlist | Vẫn ở bài hiện tại |
| 08 | Happy Path | Skip Previous — bài mới phát < 3 giây | 1) Phát bài thứ 2<br>2) Previous ngay | Queue playlist | Chuyển về bài trước |
| 09 | Happy Path | Tua (Seek) đến vị trí cụ thể | 1) Phát bài<br>2) Kéo seekbar | Bài dài | Seekbar hoạt động |
| 10 | Happy Path | Điều chỉnh âm lượng | 1) Phát bài<br>2) Kéo volume | Volume slider | Slider hoạt động |
| 11 | Happy Path | Repeat mode: Off → All → One → Off | 1) Phát bài<br>2) Nhấn Repeat 3 lần | repeat off | Icon repeat đổi đúng |
| 12 | Happy Path | Mini Player mở lại Player | 1) Phát bài<br>2) Back<br>3) Tap Mini Player | Đang playing | PlayerScreen mở lại |
| 13 | Happy Path | Tab Queue hiển thị danh sách chờ | 1) Phát queue<br>2) Mở tab Queue | Queue ≥ 1 bài | Queue item hiển thị |
| 14 | Happy Path | Chọn bài trong Queue | 1) Mở Queue<br>2) Tap item 1 | Queue trending | Item active (equalizer) |
| 15 | Happy Path | Ghi nhận Play History | 1) Phát bài<br>2) Vào History | E2E Track Two | Bài xuất hiện trong history |
| 16 | Happy Path | Tab Lyrics hiển thị lời | 1) Phát bài có lyrics<br>2) Tab Lyrics | Lyrics Track | Dòng lyrics hiển thị |

---

> **Tổng số Test Cases:** 16 (tự động hóa trong `integration_test/music_streaming_test.dart`)  
> **Phân bố:** Happy Path: 16
