# Ondas Mobile — Test Cases: Kết quả & Điều hướng Tìm kiếm (Search Results)

> **Tính năng**: Hiển thị kết quả tìm kiếm, phân trang, điều hướng đến Artist/Album, hiển thị dữ liệu đặc biệt  
> **Phiên bản**: 1.0  
> **Ngày**: 22/05/2026  
> **Loại test**: Functional E2E Test Cases (Manual / Exploratory)  
> **File gốc**: `search_discovery_test_case.md` — TCs: 15-17, 21-22, 30-32, 40-46, 82-85

---

## Thành phần liên quan

| Thành phần | Mô tả |
|---|---|
| `SearchScreen` | Màn hình Search chính — hiển thị kết quả theo sections (Songs, Artists, Albums) |
| `SearchBloc` | Quản lý state — `SearchLoaded`, `SearchLoadMoreRequested` |
| API | `GET /api/search` |
| Routes | `/songs/artist/:id`, `/songs/album/:id`, player routes |

---

## Bảng Test Cases

| STT (ID) | Nhóm | Tên Test Case | Các bước thực hiện (Steps) | Dữ liệu kiểm thử (Test Data) | Kết quả mong đợi (Expected Result) |
|---|---|---|---|---|---|
| 15 | Happy Path | Load thêm kết quả (Pagination / Infinite Scroll) khi cuộn xuống cuối danh sách | 1) Tìm kiếm từ khóa cho nhiều kết quả (>10 bài)<br>2) Cuộn xuống cuối danh sách<br>3) Quan sát | Từ khóa: "love" (nhiều kết quả); `hasMore = true` | Khi cuộn gần cuối, `SearchLoadMoreRequested` dispatch; `SearchLoadingMore` emit; danh sách được nối thêm (append) kết quả trang tiếp theo; loading indicator hiển thị ở cuối |
| 16 | Happy Path | Nhấn vào Artist tile trong kết quả → xem danh sách bài hát của Artist | 1) Tìm kiếm "The Weeknd"<br>2) Nhấn vào artist tile "The Weeknd" trong section Artists<br>3) Quan sát | Artist: id = "artist_01", name = "The Weeknd" | Điều hướng sang `/songs/artist/artist_01`; `SongListScreen` hiển thị danh sách bài hát của nghệ sĩ; `AlbumSummary` hiển thị nếu có |
| 17 | Happy Path | Nhấn vào Album tile trong kết quả → xem danh sách bài hát của Album | 1) Tìm kiếm "After Hours"<br>2) Nhấn vào album tile "After Hours" trong section Albums<br>3) Quan sát | Album: id = "album_01", title = "After Hours" | Điều hướng sang `/songs/album/album_01`; `SongListScreen` hiển thị danh sách bài hát trong album |
| 21 | Happy Path | Kết quả tìm kiếm trả về rỗng (không có dữ liệu) | 1) Mở màn Search<br>2) Nhập từ khóa không tồn tại<br>3) Quan sát | Từ khóa: "xyzqw1234notexist" | `SearchLoaded` emit với `songs`, `artists`, `albums` đều rỗng; UI hiển thị Empty State: "Không tìm thấy kết quả nào cho 'xyzqw1234notexist'" kèm icon minh họa; không lỗi |
| 22 | Happy Path | Nhấn nút "Retry" khi tìm kiếm thất bại | 1) Tắt mạng<br>2) Nhập từ khóa và submit<br>3) Bật lại mạng<br>4) Nhấn nút "Retry" trên màn lỗi | Từ khóa: "hello" | Lần 1: `SearchFailure` với message lỗi kết nối; Lần 2 (Retry): submit lại query → `SearchLoaded` hiển thị kết quả thành công |
| 30 | Boundary | Trang hiện tại = 0 (trang đầu tiên) — pagination | 1) Tìm kiếm từ khóa nhiều kết quả<br>2) Quan sát page trong state | Từ khóa: "love"; page = 0 | `SearchLoaded.page = 0`; hiển thị 10 kết quả đầu tiên; `hasMore = true` (nếu còn dữ liệu) |
| 31 | Boundary | Trang cuối cùng — không còn dữ liệu để load thêm | 1) Tìm kiếm từ khóa ít kết quả (< 10)<br>2) Cuộn xuống cuối<br>3) Quan sát | Từ khóa: "xyz_unique_song"; tổng < 10 kết quả | `hasMore = false`; không có infinite scroll trigger; không gửi `SearchLoadMoreRequested`; không hiển thị loading indicator cuối trang |
| 32 | Boundary | Size mặc định mỗi trang = 10 | 1) Tìm kiếm từ khóa trả về 25 kết quả<br>2) Load thêm trang 2 | pageSize = 10 | Trang 1: 10 kết quả; Trang 2: 10 kết quả; Trang 3: 5 kết quả; `hasMore = false` sau trang 3; tổng `totalSongs = 25` |
| 40 | Boundary | Tên nghệ sĩ quá dài (≥ 50 ký tự) | 1) Tìm kiếm từ khóa trả về artist có name dài<br>2) Quan sát Artist tile | Artist name: "A Very Long Artist Name That Exceeds Fifty Characters..." | Tên hiển thị với `TextOverflow.ellipsis`; layout không bị tràn; không crash |
| 41 | Boundary | Tên album quá dài (≥ 50 ký tự) | 1) Tìm kiếm từ khóa trả về album có title dài<br>2) Quan sát Album tile | Album title: "A Very Long Album Title That Exceeds Normal Limits..." | Tên hiển thị với `TextOverflow.ellipsis`; không tràn layout |
| 42 | Boundary | Ảnh bìa album / nghệ sĩ / bài hát = null | 1) Tìm kiếm từ khóa trả về item có `coverUrl = null` hoặc `imageUrl = null`<br>2) Quan sát tile | coverUrl: null | Hiển thị placeholder / icon mặc định; không crash; không hiển thị lỗi load ảnh |
| 43 | Boundary | Ảnh bìa trả về URL không hợp lệ (invalid URL) | 1) Tìm kiếm trả về item có `coverUrl = "not-a-valid-url"` | coverUrl: "not-a-valid-url" | Hiển thị placeholder hoặc fallback image; không crash; không hiển thị widget lỗi đỏ |
| 44 | Boundary | Ảnh bìa trả về HTTP 404 | 1) Tìm kiếm trả về item có coverUrl trỏ đến ảnh không tồn tại | coverUrl trả về 404 | Hiển thị placeholder sau khi load fail; không crash; không vỡ layout |
| 45 | Boundary | Nghệ sĩ không có bài hát nào (totalSongs = 0) | 1) Nhấn vào artist tile có `totalSongs = 0`<br>2) Quan sát SongListScreen | Artist: id = "artist_empty", totalSongs = 0 | SongListScreen hiển thị empty state: "Chưa có bài hát nào"; không crash |
| 46 | Boundary | Album không có bài hát nào (totalSongs = 0) | 1) Nhấn vào album tile có `totalSongs = 0`<br>2) Quan sát SongListScreen | Album: id = "album_empty", totalSongs = 0 | SongListScreen hiển thị empty state; không crash |
| 82 | Boundary / UX | Tab between sections trong kết quả tìm kiếm — Songs, Artists, Albums đều có dữ liệu | 1) Tìm kiếm từ khóa trả về cả 3 loại<br>2) Cuộn xuống qua từng section<br>3) Quan sát layout | Kết quả có Songs (5), Artists (3), Albums (2) | Các section hiển thị theo thứ tự: Songs → Artists → Albums; mỗi section có header với tên và số lượng; khoảng cách giữa các section hợp lý |
| 83 | Boundary / UX | Chỉ có 1 loại kết quả (vd: chỉ có Songs, không có Artists, Albums) | 1) Tìm kiếm từ khóa chỉ trả về Songs<br>2) Quan sát UI | Từ khóa chỉ có kết quả Songs; artists = [], albums = [] | Section Artists và Albums ẩn đi hoặc hiển thị "Không tìm thấy nghệ sĩ / album"; không hiển thị section trống với header 0 |
| 84 | Boundary / UX | Animation và transition khi chuyển từ Suggestions sang Results | 1) Đang ở Suggestions<br>2) Nhập từ khóa và submit<br>3) Quan sát transition | Từ khóa: "rock" | Suggestions mờ dần / biến mất; Loading indicator hiển thị (SearchLoading); sau đó Results xuất hiện; transition mượt, không giật |
| 85 | Boundary / UX | Hiển thị đúng `artistDisplay` khi một bài hát có nhiều nghệ sĩ | 1) Tìm kiếm bài hát có 3+ nghệ sĩ<br>2) Quan sát Song tile | Song artists: ["A", "B", "C"] | Hiển thị "A, B, C"; nếu quá dài, dùng ellipsis; layout không bị tràn |

---

> **Tổng số Test Cases:** 19  
> **Phân bố:** Happy Path: 5 | Boundary: 10 | Boundary/UX: 4  
> **Phạm vi:** Pagination, navigation (artist/album detail), empty results, retry, page boundaries, display (long text, null/invalid cover, empty data), sections layout, animation, multi-artist display
