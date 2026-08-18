# Kế hoạch điều chỉnh UI phần Tóm tắt tài chính

Kế hoạch này nhằm mục đích tách biệt và làm rõ ràng hơn các thành phần: Thu nhập, Chi tiêu, Biểu đồ và Số dư để tránh cảm giác bị "dính" lại với nhau.

## Các thay đổi đề xuất

### 1. Presentation Layer

#### [MODIFY] [expense_list_page.dart](file:///D:/Android/expense/lib/features/expense/presentation/pages/expense_list_page.dart)
- Chia nhỏ Card tóm tắt thành các khu vực rõ ràng hơn bằng cách sử dụng `Padding` và `Divider`.
- Tách biệt phần hiển thị Thu nhập/Chi tiêu thành một khối riêng biệt.
- Đưa Biểu đồ vào một khối có khoảng cách (margin/padding) lớn hơn.
- Làm nổi bật phần Số dư bằng một Container có màu nền nhẹ hoặc viền để phân biệt với phần dữ liệu thô.
- Tăng khoảng cách `SizedBox(height: ...)` giữa các thành phần.

## Các bước thực hiện
- [ ] Thiết kế lại cấu trúc `Column` trong Card tóm tắt.
- [ ] Thêm các khoảng trống `Spacer` hoặc `SizedBox` phù hợp.
- [ ] Cải thiện kiểu dáng cho phần "Số dư" để nó trông giống như một kết quả tổng kết.
