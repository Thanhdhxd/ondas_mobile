# Ondas Mobile — Test Cases: Bảo mật, Edge Cases & UX Playlist

> **Tính năng**: SQL Injection, XSS, validation API, auth bypass, loading states, double tap, batch, app kill  
> **Phiên bản**: 1.0  
> **Ngày**: 22/05/2026  
> **Loại test**: Functional E2E Test Cases (Manual / Exploratory)  
> **File gốc**: `playlist_management_test_case.md` — TCs: 45-51, 57-60

---

## Bảng Test Cases

| STT (ID) | Nhóm | Tên Test Case | Các bước thực hiện (Steps) | Dữ liệu kiểm thử (Test Data) | Kết quả mong đợi (Expected Result) |
|---|---|---|---|---|---|
| 45 | Negative | SQL Injection trong tên playlist | 1) Mở dialog tạo playlist<br>2) Nhập chuỗi SQL injection<br>3) Nhấn "Tạo" | Tên: "'; DROP TABLE playlists; --" | Input được xử lý an toàn (parameterized query); playlist được tạo với đúng tên đã nhập hoặc bị escape; không có SQL được thực thi |
| 46 | Negative | XSS trong tên playlist | 1) Mở dialog tạo playlist<br>2) Nhập chuỗi script<br>3) Nhấn "Tạo" | Tên: "&lt;script&gt;alert('xss')&lt;/script&gt;" | Tên hiển thị dưới dạng text thuần, script không được thực thi; không có alert popup; UI an toàn |
| 47 | Negative | Gửi request thêm bài hát với songId rỗng | 1) Thử gọi API add song với songId = "" | songId: ""; playlistId: "pl_01" | Server từ chối với lỗi validation 400; hiển thị thông báo lỗi phù hợp; không crash |
| 48 | Negative | Gửi request thêm bài hát với playlistId rỗng | 1) Thử gọi API add song với playlistId = "" | songId: "song_01"; playlistId: "" | Server từ chối với lỗi validation 400; hiển thị thông báo lỗi; không crash |
| 49 | Negative | Tạo playlist khi chưa đăng nhập (nếu bypass được guard) | 1) Chưa đăng nhập / token không hợp lệ<br>2) Thử tạo playlist | Không có token | Route guard chặn và redirect về Login; nếu bypass được, API trả về 401 Unauthorized |
| 50 | Negative | Đổi tên playlist của người khác (qua API) | 1) Lấy id playlist của user khác<br>2) Gửi request đổi tên | Playlist id của user khác; tên mới: "Hacked" | Server trả về 403 Forbidden; tên không bị đổi; hiển thị lỗi |
| 51 | Negative | Reorder playlist với danh sách songIds không khớp (thiếu/bị thừa) | 1) Gửi request reorder với songIds khác với thực tế | songIds gửi lên: ["A", "C"] (thiếu "B" đang có trong playlist) | Server trả về lỗi validation 400: "Danh sách bài hát không khớp"; UI revert về trạng thái cũ |
| 57 | Boundary / UX | Bottom sheet hiển thị loading khi đang fetch danh sách playlist | 1) Mở SaveToPlaylistBottomSheet<br>2) Quan sát ngay khi mở (trước khi API trả về) | Mạng bình thường hoặc chậm | Hiển thị loading indicator (CircularProgressIndicator); sau đó hiển thị danh sách playlist; không hiển thị màn trắng |
| 58 | Negative | Nhấn nút "Tạo playlist" nhiều lần liên tục (double tap) | 1) Mở dialog tạo playlist<br>2) Nhập tên hợp lệ<br>3) Nhấn nút "Tạo" 2 lần thật nhanh | Tên: "Double Tap" | Nút bị disable sau lần nhấn đầu tiên; chỉ tạo 1 playlist duy nhất; không tạo trùng |
| 59 | Negative | Thêm > 1 bài hát cùng lúc vào playlist (batch add — nếu có) | 1) Chọn nhiều bài hát (multi-select)<br>2) Thêm vào playlist<br>3) Quan sát | 5 bài hát được chọn; thêm vào playlist "Bulk Add" | Nếu UI hỗ trợ multi-select: tất cả 5 bài được thêm; totalSongs +5; nếu không hỗ trợ: chức năng không khả dụng |
| 60 | Negative | Ứng dụng bị kill khi đang thực hiện thêm bài hát vào playlist | 1) Mở bottom sheet<br>2) Chọn playlist để thêm bài hát<br>3) Kill app ngay sau khi nhấn toggle | Đang gọi API add song; force kill app | App khởi động lại bình thường; trạng thái bài hát trong playlist tùy thuộc vào API đã hoàn thành hay chưa; không crash, không corrupt data |

---

> **Tổng số Test Cases:** 11  
> **Phân bố:** Negative: 9 | Boundary/UX: 2  
> **Phạm vi:** SQL Injection, XSS, empty songId/playlistId validation, auth bypass, unauthorized rename, invalid reorder, loading state, double tap prevention, batch add, app kill
