# Ondas Mobile — Test Cases: Quản lý Bài hát trong Playlist

> **Tính năng**: Thêm/xóa bài hát, reorder, toggle, swipe delete, play from playlist  
> **Phiên bản**: 1.0  
> **Ngày**: 22/05/2026  
> **Loại test**: Functional E2E Test Cases (Manual / Exploratory)  
> **File gốc**: `playlist_management_test_case.md` — TCs: 03-05, 08, 12, 20-22, 26-28, 52-56

---

## Thành phần liên quan

| Thành phần | Mô tả |
|---|---|
| `SaveToPlaylistBottomSheet` | Bottom sheet hiển thị danh sách playlist — toggle thêm/xóa bài hát |
| `PlaylistDetailScreen` | Màn hình chi tiết — swipe delete, reorder (drag & drop), Play All |
| `PlaylistBloc` | Quản lý state — add/remove song, reorder |

---

## Bảng Test Cases

| STT (ID) | Nhóm | Tên Test Case | Các bước thực hiện (Steps) | Dữ liệu kiểm thử (Test Data) | Kết quả mong đợi (Expected Result) |
|---|---|---|---|---|---|
| 03 | Happy Path | Thêm bài hát vào playlist hiện có — từ SaveToPlaylistBottomSheet | 1) Phát một bài hát chưa có trong playlist<br>2) Mở PlayerScreen → chọn "Thêm vào playlist"<br>3) Chọn một playlist hiện có (chưa chứa bài hát này)<br>4) Quan sát UI toggle | Song id: "song_02"; Playlist id: "pl_01"; `containsSong = false` ban đầu | Toggle chuyển sang trạng thái đã chọn (checked); `totalSongs` tăng +1; `containsSong = true`; bài hát được thêm vào playlist |
| 04 | Happy Path | Xóa bài hát khỏi playlist — từ SaveToPlaylistBottomSheet | 1) Phát một bài hát đã có trong playlist<br>2) Mở PlayerScreen → chọn "Thêm vào playlist"<br>3) Bỏ chọn playlist đang chứa bài hát<br>4) Quan sát UI toggle | Song id: "song_03"; Playlist id: "pl_01"; `containsSong = true` ban đầu | Toggle chuyển sang trạng thái bỏ chọn (unchecked); `totalSongs` giảm -1; `containsSong = false`; bài hát bị xóa khỏi playlist |
| 05 | Happy Path | Xóa bài hát khỏi playlist — từ PlaylistDetailScreen (swipe/delete) | 1) Mở một playlist có ≥ 3 bài hát<br>2) Vuốt trái (swipe to delete) một bài hát<br>3) Xác nhận xóa | Playlist: "My Mix" (3 bài); xóa bài ở vị trí thứ 2 | Bài hát bị xóa khỏi danh sách; `totalSongs` giảm 1; danh sách được re-index (position cập nhật đúng 1, 2); không crash |
| 08 | Happy Path | Sắp xếp lại (Reorder) bài hát trong playlist | 1) Mở playlist có ≥ 3 bài hát<br>2) Kéo thả (drag & drop) bài hát từ vị trí 3 lên vị trí 1<br>3) Quan sát thứ tự mới | Playlist: [A(pos=1), B(pos=2), C(pos=3)]; kéo C lên đầu | Thứ tự mới: [C(pos=1), A(pos=2), B(pos=3)]; `position` được cập nhật đúng; UI hiển thị đúng thứ tự |
| 12 | Happy Path | Toggle thêm/xóa bài hát vào nhiều playlist cùng lúc | 1) Mở SaveToPlaylistBottomSheet với 1 bài hát<br>2) Chọn playlist A (thêm bài hát)<br>3) Chọn playlist B (thêm bài hát)<br>4) Bỏ chọn playlist A (xóa bài hát) | Song: id="song_05"; Playlist A và B chưa chứa bài | Từng toggle hoạt động độc lập; bài hát được thêm vào B, xóa khỏi A; trạng thái từng playlist đúng |
| 20 | Boundary | Thêm bài hát vào playlist đã có ≥ 1000 bài | 1) Chọn playlist có 1000 bài<br>2) Thêm 1 bài hát mới<br>3) Quan sát | Playlist: 1000 bài; thêm bài thứ 1001 | Thêm thành công; `totalSongs = 1001`; không crash; không bị giới hạn (trừ khi server có limit) |
| 21 | Boundary | Xóa bài hát cuối cùng khỏi playlist | 1) Mở playlist chỉ có 1 bài hát<br>2) Xóa bài hát đó (swipe hoặc toggle)<br>3) Quan sát | Playlist: [Song A] (1 bài) | Bài hát bị xóa; playlist trở thành rỗng (totalSongs = 0); hiển thị "Chưa có bài hát nào" hoặc empty state; không crash |
| 22 | Boundary | Xóa bài hát khỏi playlist rỗng (edge case) | 1) Mở playlist rỗng (0 bài)<br>2) Thử xóa bài hát (nếu UI cho phép) | Playlist: rỗng, totalSongs = 0 | Không có bài nào để xóa; UI hiển thị empty state; không có action delete khả dụng; không crash |
| 26 | Boundary | Reorder playlist — kéo bài hát xuống cuối cùng | 1) Mở playlist ≥ 3 bài<br>2) Kéo bài đầu tiên xuống vị trí cuối cùng | Playlist: [A(1), B(2), C(3)]; kéo A xuống cuối | Thứ tự mới: [B(1), C(2), A(3)]; position cập nhật đúng; không crash |
| 27 | Boundary | Reorder playlist — kéo bài hát lên đầu tiên | 1) Mở playlist ≥ 3 bài<br>2) Kéo bài cuối cùng lên vị trí đầu tiên | Playlist: [A(1), B(2), C(3)]; kéo C lên đầu | Thứ tự mới: [C(1), A(2), B(3)]; position cập nhật đúng |
| 28 | Boundary | Reorder playlist — kéo nhưng thả lại vị trí cũ (không đổi) | 1) Mở playlist<br>2) Kéo một bài hát rồi thả lại đúng vị trí cũ | Kéo A từ vị trí 1 thả lại vị trí 1 | API reorder có thể không được gọi (detect unchanged); UI không thay đổi; không lỗi |
| 52 | Boundary / UX | SaveToPlaylistBottomSheet hiển thị đúng trạng thái checked/unchecked | 1) Mở bottom sheet cho bài hát "song_01"<br>2) Quan sát danh sách playlist<br>3) Đóng bottom sheet | Bài hát đã có trong playlist A (checked), chưa có trong B (unchecked) | Playlist A hiển thị icon check; Playlist B hiển thị icon add/uncheck; đúng với `containsSong` |
| 53 | Boundary / UX | Toggle nhanh (rapid toggle) một playlist trong SaveToPlaylistBottomSheet | 1) Mở bottom sheet<br>2) Nhấn toggle playlist A liên tục 5 lần trong 2 giây | Playlist A đang unchecked | Sau khi dừng, trạng thái cuối cùng đúng với API response; không bị duplicate request; optimistic update revert đúng nếu API fail |
| 54 | Boundary / UX | Kéo để làm mới (Pull-to-refresh) khi danh sách playlist đang rỗng | 1) Xóa tất cả playlist<br>2) Vào Library<br>3) Kéo xuống để refresh | User có 0 playlist | Hiển thị empty state: "Chưa có playlist nào" kèm icon/illustration; refresh không lỗi |
| 55 | Boundary / UX | PlaylistDetail: Phát tất cả (Play All) bài hát trong playlist | 1) Mở playlist có ≥ 3 bài hát<br>2) Nhấn nút "Play All" (hoặc Shuffle Play)<br>3) Quan sát | Playlist: [A, B, C] | Tất cả bài hát được đưa vào Player queue; bắt đầu phát từ bài đầu tiên; PlayerScreen mở ra |
| 56 | Boundary / UX | PlaylistDetail: Chạm vào một bài hát để phát | 1) Mở playlist<br>2) Chạm vào bài hát thứ 3 trong danh sách<br>3) Quan sát | Playlist: 5 bài; chạm bài thứ 3 | Player phát bài thứ 3; queue = toàn bộ bài trong playlist; index = 2 (0-based) |

---

> **Tổng số Test Cases:** 16  
> **Phân bố:** Happy Path: 5 | Boundary: 6 | Boundary/UX: 5  
> **Phạm vi:** Add/remove song (toggle + swipe), reorder (drag & drop), multi-toggle, 1000+ songs, empty playlist, rapid toggle, Play All, play from playlist
