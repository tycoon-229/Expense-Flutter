# Walkthrough - Expense Tracker App

Ứng dụng quản lý chi tiêu đơn giản đã được xây dựng hoàn tất với kiến trúc sạch (**Clean Architecture**) và đầy đủ các tính năng yêu cầu.

## Các thành phần chính

### 🏗 Kiến trúc dự án
Dự án được chia theo các lớp rõ ràng:
- **Core**: Chứa các thành phần dùng chung như DI (`get_it`), Error handling và UseCase base.
- **Data**: Xử lý dữ liệu với Hive (Local Database).
- **Domain**: Chứa Business Logic (Entities, Repositories interface, UseCases).
- **Presentation**: Giao diện người dùng với BLoC, Widgets và Pages.

### 🎨 Giao diện & Hiệu ứng
- **Material 3**: Giao diện hiện đại, màu sắc tươi sáng.
- **Animations**: Sử dụng `animate_do` để tạo hiệu ứng xuất hiện cho danh sách chi tiêu.
- **Charts**: Tích hợp `fl_chart` để hiển thị biểu đồ phân bổ chi tiêu theo danh mục.

### 🛠 Các thư viện đã sử dụng
- `flutter_bloc`: Quản lý trạng thái.
- `get_it` & `injectable`: Dependency Injection.
- `hive_flutter`: Lưu trữ dữ liệu local.
- `go_router`: Điều hướng.
- `fl_chart`: Vẽ biểu đồ.
- `animate_do`: Hiệu ứng mượt mà.

## Các màn hình và tính năng
1. **Danh sách chi tiêu**: Hiển thị tổng quan bằng biểu đồ tròn và danh sách chi tiết.
2. **Thêm chi tiêu**: Dialog cho phép nhập tên, số tiền và chọn danh mục.
3. **Xóa chi tiêu**: Sử dụng hành động vuốt (Swipe to dismiss).

## Hướng dẫn chạy ứng dụng
1. Đảm bảo bạn đã cài đặt Flutter.
2. Chạy lệnh `flutter pub get` để cập nhật dependencies.
3. Chạy ứng dụng bằng `flutter run`.

> [!TIP]
> Bạn có thể thay đổi màu sắc chủ đạo của ứng dụng trong `lib/main.dart` tại phần `ColorScheme.fromSeed`.
