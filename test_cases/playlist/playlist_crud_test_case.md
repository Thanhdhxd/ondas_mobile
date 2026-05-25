# Ondas Mobile — Test Cases: CRUD Playlist (Tạo, Đổi tên, Xóa, Xem)

> **Tính năng**: Tạo playlist, đổi tên, xóa playlist, xem danh sách/chi tiết, validation  
> **Phiên bản**: 1.0  
> **Ngày**: 22/05/2026  
> **Loại test**: Functional E2E Test Cases (Manual / Exploratory)  
> **File gốc**: `playlist_management_test_case.md` — TCs: 01-02, 06-07, 09-11, 13-19, 23-25

---

## Thành phần liên quan

| Thành phần | Mô tả |
|---|---|
| `LibraryScreen` | Màn hình Library — hiển thị danh sách playlist |
| `PlaylistDetailScreen` | Màn hình chi tiết playlist — danh sách bài hát, Play All, reorder |
| `PlaylistBloc` | Quản lý state playlist — CRUD operations |
| `CreatePlaylistDialog` | Dialog tạo/đổi tên playlist — validation tên |

---

## Bảng Test Cases

| STT (ID) | Nhóm | Tên Test Case | Các bước thực hiện (Steps) | Dữ liệu kiểm thử (Test Data) | Kết quả mong đợi (Expected Result) |
|---|---|---|---|---|---|
| 01 | Happy Path | Tạo playlist mới thành công với dữ liệu hợp lệ | 1) Mở màn Library<br>2) Nhấn nút tạo playlist mới<br>3) Nhập tên playlist hợp lệ<br>4) Nhấn "Tạo" | Tên playlist: "My Summer Mix" | Dialog đóng; playlist mới xuất hiện trong danh sách Library với tên "My Summer Mix", `totalSongs = 0`, `coverUrl = null` |
| 02 | Happy Path | Tạo playlist mới từ SaveToPlaylistBottomSheet (từ Player) | 1) Phát một bài hát<br>2) Mở PlayerScreen<br>3) Nhấn nút "Thêm vào playlist"<br>4) Chọn "Tạo playlist mới"<br>5) Nhập tên và xác nhận | Tên: "Lofi Chill"; Song: id="song_01" | Playlist mới được tạo; bài hát hiện tại tự động được thêm vào playlist mới; `containsSong = true` cho playlist đó |
| 06 | Happy Path | Đổi tên playlist thành công | 1) Mở một playlist<br>2) Nhấn vào tên playlist để chỉnh sửa<br>3) Nhập tên mới hợp lệ<br>4) Xác nhận | Tên cũ: "Old Name"; Tên mới: "Fresh Vibes" | Tên playlist cập nhật thành "Fresh Vibes"; hiển thị đúng trên màn detail, library, và bottom sheet |
| 07 | Happy Path | Xóa toàn bộ playlist | 1) Mở Library, chọn một playlist<br>2) Nhấn nút "Xóa playlist" (delete)<br>3) Xác nhận xóa trong dialog confirm | Playlist: "Temporary Mix" (2 bài) | Playlist bị xóa khỏi danh sách Library; không còn xuất hiện trong SaveToPlaylistBottomSheet; tổng số playlist giảm 1 |
| 09 | Happy Path | Xem danh sách playlist trong Library | 1) Đăng nhập tài khoản đã có ≥ 3 playlist<br>2) Vào tab Library<br>3) Quan sát danh sách playlist | User có 3 playlist: "Rock", "Pop", "Jazz" | Hiển thị đầy đủ 3 playlist với tên, ảnh bìa (nếu có), số bài hát; sắp xếp theo thứ tự gần đây nhất |
| 10 | Happy Path | Xem chi tiết playlist (PlaylistDetailScreen) | 1) Mở một playlist bất kỳ<br>2) Quan sát màn hình chi tiết | Playlist: "Summer Hits" (5 bài) | Hiển thị: tên playlist, ảnh bìa, tổng số bài hát, danh sách bài hát với đầy đủ title, artists, cover, duration; có nút Play All |
| 11 | Happy Path | Làm mới danh sách playlist (Pull-to-refresh) | 1) Vào Library<br>2) Kéo xuống để refresh<br>3) Quan sát | Có playlist mới được tạo từ thiết bị khác | Danh sách playlist được tải lại; playlist mới từ server xuất hiện; UI loading indicator hiển thị trong lúc refresh |
| 13 | Boundary | Tạo playlist với tên rỗng (empty) | 1) Mở dialog tạo playlist<br>2) Để trống tên<br>3) Nhấn "Tạo" | Tên: (trống) | Hiển thị lỗi validation: "Vui lòng nhập tên playlist"; không cho tạo; dialog vẫn mở |
| 14 | Boundary | Tạo playlist với tên chỉ gồm khoảng trắng | 1) Mở dialog tạo playlist<br>2) Nhập tên chỉ gồm khoảng trắng<br>3) Nhấn "Tạo" | Tên: "&nbsp;&nbsp;&nbsp;&nbsp;" (nhiều space) | Trim về rỗng → hiển thị lỗi validation "Vui lòng nhập tên playlist"; không cho tạo |
| 15 | Boundary | Tạo playlist với tên đúng độ dài tối thiểu (1 ký tự) | 1) Mở dialog tạo playlist<br>2) Nhập tên 1 ký tự<br>3) Nhấn "Tạo" | Tên: "A" | Tạo thành công; playlist hiển thị tên "A" trong Library |
| 16 | Boundary | Tạo playlist với tên đạt độ dài tối đa (vd: 100 ký tự) | 1) Mở dialog tạo playlist<br>2) Nhập tên 100 ký tự<br>3) Nhấn "Tạo" | Tên: "A" × 100 | Tạo thành công; tên hiển thị đầy đủ hoặc bị cắt bằng ellipsis tùy UI; không crash |
| 17 | Boundary | Tạo playlist với tên vượt độ dài tối đa (101+ ký tự) | 1) Mở dialog tạo playlist<br>2) Nhập tên 101+ ký tự<br>3) Nhấn "Tạo" | Tên: "A" × 101 | Không cho nhập thêm ký tự (maxLength) hoặc hiển thị lỗi validation "Tên playlist quá dài"; không tạo được |
| 18 | Boundary | Tạo playlist với tên có khoảng trắng đầu/cuối | 1) Mở dialog tạo playlist<br>2) Nhập tên có khoảng trắng đầu/cuối<br>3) Nhấn "Tạo" | Tên: "&nbsp;&nbsp;My&nbsp;Mix&nbsp;&nbsp;" (space đầu cuối) | Tên được trim trước khi gửi API; playlist tạo với tên "My Mix"; không có khoảng trắng thừa |
| 19 | Boundary | Tên playlist chứa ký tự đặc biệt và emoji | 1) Mở dialog tạo playlist<br>2) Nhập tên chứa emoji và ký tự đặc biệt<br>3) Nhấn "Tạo" | Tên: "🎵 Summer Vibes! #2024 🌊" | Tạo thành công; emoji và ký tự đặc biệt hiển thị đúng; không bị lỗi encode |
| 23 | Boundary | Đổi tên playlist thành tên giống hệt tên cũ | 1) Mở playlist tên "Rock Classics"<br>2) Đổi tên thành "Rock Classics" (giống hệt)<br>3) Xác nhận | Tên cũ = Tên mới = "Rock Classics" | API vẫn được gọi (hoặc bỏ qua nếu phát hiện không đổi); không lỗi; tên giữ nguyên |
| 24 | Boundary | Đổi tên playlist dài đúng bằng max length | 1) Mở playlist<br>2) Đổi tên thành chuỗi 100 ký tự<br>3) Xác nhận | Tên mới: "A" × 100 | Đổi tên thành công; tên mới hiển thị đúng (có thể bị ellipsis) |
| 25 | Boundary | Đổi tên playlist thành chuỗi rỗng | 1) Mở playlist<br>2) Xóa hết tên, để trống<br>3) Xác nhận | Tên mới: (trống) | Hiển thị lỗi validation "Tên playlist không được để trống"; không cho lưu |

---

> **Tổng số Test Cases:** 17  
> **Phân bố:** Happy Path: 7 | Boundary: 10  
> **Phạm vi:** Create playlist (from Library + Bottom Sheet), rename, delete, view list/detail, refresh, name validation (empty/spaces/min/max/over max/trim/emoji/same name)
