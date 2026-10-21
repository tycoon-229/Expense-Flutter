# 💰 Expense Tracker App

Ứng dụng quản lý tài chính và chi tiêu cá nhân hiện đại được xây dựng bằng **Flutter**, áp dụng kiến trúc chuẩn **Clean Architecture** kết hợp mô hình quản lý trạng thái **BLoC/Cubit**, cơ sở dữ liệu đám mây **Supabase**, hệ thống thông báo định kỳ và đồ thị phân tích thông minh.

---

## ✨ Tính năng nổi bật

### 1. 💵 Quản lý Thu - Chi (Expense & Income)
* **Ghi chép linh hoạt:** Hỗ trợ tạo, cập nhật, xóa nhanh các khoản thu và chi tiêu.
* **Bộ lọc nâng cao:** Lọc theo loại giao dịch (Thu / Chi), theo tháng/năm, hoặc theo từng danh mục cụ thể.
* **Thống kê tổng quan:** Thẻ số dư ví, tổng thu nhập và tổng chi tiêu được tính toán tự động tức thì.
* **Tìm kiếm thông minh:** Tìm kiếm nhanh giao dịch theo tiêu đề hoặc ghi chú.

### 2. 📊 Báo cáo & Phân tích chuyên sâu (Analytics & Charts)
* **Biểu đồ tròn (Pie Chart):** Trực quan hóa tỷ trọng chi tiêu hoặc thu nhập theo từng danh mục.
* **Biểu đồ cột + đường xu hướng (Weekly Bar & Line Chart):** Theo dõi tình hình chi tiêu trong 7 ngày gần nhất, giúp nhận biết ngày chi tiêu đột biến và xu hướng tài chính.
* **Thống kê theo tháng:** Chuyển đổi và theo dõi số liệu của các tháng trước đó dễ dàng.

### 3. 🏷️ Danh mục & Hạn mức ngân sách (Categories & Budgets)
* **Tự do tùy biến danh mục:** Thêm mới, chỉnh sửa màu sắc, và lựa chọn từ bộ sưu tập hơn 60+ icon sinh động phù hợp với từng hoạt động (ăn uống, giải trí, giáo dục, mua sắm...).
* **Hạn mức chi tiêu hàng tháng:** Cài đặt giới hạn ngân sách tối đa cho từng danh mục trong tháng.
* **Thanh tiến trình trực quan:** Hiển thị phần trăm đã chi tiêu, tự động đổi màu cảnh báo khi gần chạm hoặc vượt quá hạn mức cho phép.

### 4. 🔁 Khoản thu chi cố định (Recurring Transactions)
* **Quản lý khoản cố định:** Lưu trữ các khoản thu chi phát sinh đều đặn hàng tháng (tiền thuê nhà, hóa đơn điện nước, gói mạng, lương...).
* **Tự động ghi nhận:** Ứng dụng tự động kiểm tra và ghi nhận các khoản thu chi đến ngày đáo hạn khi mở app, không sợ bị quên.
* **Linh hoạt:** Bật/tắt trạng thái tự động ghi nhận bất cứ lúc nào.

### 5. 🔔 Nhắc nhở ghi chép hàng ngày (Daily Notifications)
* **Thông báo định kỳ:** Gửi thông báo nhắc nhở người dùng cập nhật sổ thu chi vào khung giờ đã thiết lập.
* **Trang cài đặt thông báo:** Tùy chọn giờ/phút nhắc nhở, bật/tắt dịch vụ và nút kiểm tra thông báo thử nghiệm trực tiếp.

### 6. 🔐 Xác thực & Bảo mật (Authentication)
* Đăng ký, đăng nhập an toàn thông qua **Supabase Authentication**.
* Tự động điều hướng và bảo vệ luồng truy cập với **GoRouter**.

### 7. 🎨 Giao diện & Trải nghiệm (UI/UX)
* Thiết kế chuẩn **Material 3** với bảng màu Deep Purple sang trọng.
* Hiệu ứng chuyển động mượt mà (FadeInDown, FadeInUp, SlideIn) bằng thư viện **animate_do**.
* Thanh điều hướng đáy 4 tab tiện lợi: **Sổ chi tiêu**, **Thống kê**, **Danh mục**, **Cố định**.

---

## 🏗️ Cấu trúc dự án (Clean Architecture)

```text
lib/
├── core/
│   ├── di/                               # Cấu hình Dependency Injection (GetIt, Injectable)
│   ├── error/                            # Định nghĩa Failure & Exception
│   ├── navigation/                       # Định tuyến điều hướng với GoRouter
│   ├── services/                         # Dịch vụ thông báo (DailyReminderService) & UI cài đặt
│   ├── usecase/                          # Khung cơ sở UseCase
│   └── utils/                            # Helper xử lý icon, định dạng số, tiền tệ
│
├── features/
│   ├── auth/                             # Xác thực tài khoản (Login / Register)
│   │   └── presentation/pages/
│   │
│   ├── category/                         # Quản lý danh mục & hạn mức chi tiêu
│   │   ├── data/ (datasources, models, repositories)
│   │   ├── domain/ (entities, repositories)
│   │   └── presentation/ (bloc, pages, widgets)
│   │
│   ├── expense/                          # Sổ thu chi & Phân tích thống kê
│   │   ├── data/ (datasources, models, repositories)
│   │   ├── domain/ (entities, repositories, usecases, utils)
│   │   └── presentation/ (bloc, pages, widgets)
│   │
│   ├── home/                             # Thanh điều hướng chính (MainNavigationPage)
│   │   └── presentation/pages/
│   │
│   └── recurring/                        # Khoản thu chi cố định hàng tháng
│       ├── data/ (datasources, models)
│       ├── domain/ (entities)
│       └── presentation/ (pages)
│
└── main.dart                             # Khởi tạo App & các dịch vụ nền tảng
```

---

## 🛠️ Công nghệ & Thư viện sử dụng

| Thư viện | Phiên bản | Chức năng |
| :--- | :--- | :--- |
| `flutter_bloc` | `^8.1.6` | Quản lý trạng thái (State Management) theo BLoC/Cubit |
| `supabase_flutter` | `^2.8.0` | Backend as a Service (Database PostgreSQL + Authentication) |
| `go_router` | `^14.2.0` | Quản lý điều hướng màn hình & bảo vệ route đăng nhập |
| `get_it` & `injectable` | `^7.7.0` / `^2.5.0` | Quản lý phụ thuộc (Dependency Injection) |
| `fl_chart` | `^0.70.1` | Vẽ biểu đồ tròn phân bổ & biểu đồ cột xu hướng |
| `animate_do` | `^3.3.4` | Hiệu ứng chuyển động (animations) cho UI |
| `flutter_local_notifications` | `^17.2.2` | Quản lý và lập lịch thông báo cục bộ |
| `shared_preferences` | `^2.3.2` | Lưu trữ cấu hình cục bộ (cài đặt thông báo, khoản cố định) |
| `intl` | `^0.20.2` | Định dạng tiền tệ VND (`₫`) và ngày tháng |

---

## 🗄️ Cấu hình Supabase Database

Để ứng dụng hoạt động đầy đủ tính năng, thực hiện chạy các câu lệnh SQL sau trong **Supabase SQL Editor**:

```sql
-- 1. Bảng Categories
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  color TEXT NOT NULL,
  type TEXT NOT NULL,           -- 'expense' hoặc 'income'
  icon TEXT DEFAULT 'category', -- Tên icon từ CategoryIconHelper
  monthly_budget NUMERIC DEFAULT NULL, -- Hạn mức chi tiêu tháng
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Bảng Expenses
CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  type TEXT NOT NULL,           -- 'expense' hoặc 'income'
  date TIMESTAMPTZ NOT NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  category_name TEXT,
  category_color TEXT,
  category_icon TEXT,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Bảng Recurring Transactions (Khoản thu chi cố định & định kỳ)
CREATE TABLE IF NOT EXISTS recurring_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  type TEXT NOT NULL,                         -- 'expense' hoặc 'income'
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  category_name TEXT,
  category_color TEXT,
  category_icon TEXT,
  frequency TEXT NOT NULL DEFAULT 'monthly',  -- 'daily', 'weekly', 'monthly', 'yearly'
  day_of_month INT DEFAULT 1,                 -- 1 -> 31
  day_of_week INT DEFAULT 1,                  -- 1 (Thứ 2) -> 7 (Chủ nhật)
  month_of_year INT DEFAULT 1,                -- 1 -> 12
  note TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_executed_key TEXT,                     -- Khóa đánh dấu lần chạy gần nhất
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Bật Row Level Security (RLS) cho recurring_transactions
ALTER TABLE recurring_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own recurring transactions"
ON recurring_transactions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own recurring transactions"
ON recurring_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own recurring transactions"
ON recurring_transactions FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own recurring transactions"
ON recurring_transactions FOR DELETE USING (auth.uid() = user_id);
```

---

## 🚀 Hướng dẫn cài đặt & Chạy ứng dụng

### 1. Chuẩn bị môi trường
* Đã cài đặt [Flutter SDK](https://flutter.dev/docs/get-started/install) (khuyên dùng Flutter 3.24+).
* Đã cấu hình Android SDK và Java 17+.

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Sinh mã tự động (Dependency Injection & Models)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Cấu hình Supabase
Mở file [`lib/main.dart`](file:///c:/Users/ACER/Android/flutter/Expense-Flutter/lib/main.dart) và cập nhật thông tin dự án Supabase của bạn:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  publishableKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 5. Chạy ứng dụng
```bash
flutter run
```

---

## 👨‍💻 Tác giả & Giấy phép

Được phát triển với ❤️ bằng **Flutter** & **Supabase**.
