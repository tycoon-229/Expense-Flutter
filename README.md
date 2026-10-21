# 💰 Expense Tracker App

Ứng dụng quản lý chi tiêu đơn giản được xây dựng bằng **Flutter**, áp dụng kiến trúc **Clean Architecture** và các công nghệ hiện đại để quản lý trạng thái, lưu trữ dữ liệu đám mây Supabase, điều hướng và hiển thị biểu đồ.

## ✨ Tổng quan

**Expense Tracker App** hỗ trợ người dùng quản lý các khoản chi tiêu cá nhân một cách đơn giản và trực quan.

Ứng dụng cung cấp các chức năng chính:

* 🔐 Đăng ký / Đăng nhập tài khoản an toàn với Supabase Authentication.
* 📊 Xem tổng quan các khoản chi tiêu và thu nhập.
* 🥧 Hiển thị biểu đồ phân bổ chi tiêu theo danh mục.
* ➕ Thêm và chỉnh sửa khoản chi tiêu / thu nhập.
* 🗑️ Xóa khoản chi tiêu bằng thao tác vuốt.
* ☁️ Đồng bộ và lưu trữ dữ liệu trực tuyến trên Supabase.
* 🎨 Giao diện Material 3 hiện đại.
* ✨ Hiệu ứng chuyển động cho danh sách chi tiêu.

---

## 🏗️ Kiến trúc dự án

Dự án được xây dựng theo mô hình **Clean Architecture**, giúp tách biệt giao diện, business logic và tầng dữ liệu.

Cấu trúc chính gồm:

```text
lib/
├── core/
│   ├── di/
│   ├── error/
│   ├── navigation/
│   └── usecase/
│
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── pages/ (login_page.dart, register_page.dart)
│   └── expense/
│       ├── data/
│       │   ├── models/
│       │   ├── datasources/
│       │   └── repositories/
│       ├── domain/
│       └── presentation/
```

### Data

Chịu trách nhiệm xử lý và lưu trữ dữ liệu. Ứng dụng sử dụng **Supabase** làm backend service để đồng bộ dữ liệu đám mây.

---

## 🛠️ Công nghệ & Thư viện

| Thư viện           | Chức năng                            |
| ------------------ | ------------------------------------ |
| `flutter_bloc`     | Quản lý trạng thái ứng dụng          |
| `get_it`           | Dependency Injection                 |
| `injectable`       | Hỗ trợ cấu hình Dependency Injection |
| `supabase_flutter` | Đồng bộ dữ liệu & Authentication     |
| `go_router`        | Điều hướng định tuyến màn hình       |
| `fl_chart`         | Hiển thị biểu đồ chi tiêu            |
| `animate_do`       | Tạo hiệu ứng chuyển động             |
| Flutter            | Framework phát triển ứng dụng        |

---

## 👨‍💻 Author

**Expense Tracker App**

Built with ❤️ using Flutter & Supabase.
