# 💰 Expense Tracker App (Quản Lý Chi Tiêu)

Ứng dụng quản lý tài chính và chi tiêu cá nhân hiện đại được xây dựng bằng **Flutter**, áp dụng kiến trúc chuẩn **Clean Architecture** kết hợp mô hình quản lý trạng thái **BLoC/Cubit**, cơ sở dữ liệu đám mây **Supabase**, hệ thống thông báo định kỳ, tối ưu hóa khởi động tức thì và đồ thị phân tích tài chính thông minh.

---

## ✨ Tính năng nổi bật

### 1. 💵 Quản lý Thu - Chi (Expense & Income)
* **Ghi chép linh hoạt:** Hỗ trợ tạo, cập nhật, xóa nhanh các khoản thu và chi tiêu cá nhân.
* **Bộ lọc nâng cao:** Lọc theo loại giao dịch (Thu / Chi), theo tháng/năm, hoặc theo từng danh mục cụ thể.
* **Thống kê tổng quan:** Thẻ số dư ví, tổng thu nhập và tổng chi tiêu được tính toán tự động tức thì.
* **Tìm kiếm thông minh:** Tìm kiếm nhanh giao dịch theo tiêu đề hoặc ghi chú.

### 2. 📊 Báo cáo & Phân tích chuyên sâu (Analytics & Charts)
* **Biểu đồ tròn (Pie Chart):** Trực quan hóa tỷ trọng chi tiêu hoặc thu nhập theo từng danh mục với `fl_chart`.
* **Biểu đồ cột + đường xu hướng (Weekly Bar & Line Chart):** Theo dõi tình hình chi tiêu trong 7 ngày gần nhất, giúp nhận biết ngày chi tiêu đột biến và xu hướng tài chính.
* **Thống kê theo tháng:** Chuyển đổi và theo dõi số liệu của các tháng trước đó dễ dàng.

### 3. 🏷️ Danh mục & Hạn mức ngân sách (Categories & Budgets)
* **Tự do tùy biến danh mục:** Thêm mới, chỉnh sửa màu sắc, và lựa chọn từ bộ sưu tập hơn 60+ icon sinh động phù hợp với từng hoạt động (ăn uống, giải trí, giáo dục, mua sắm...).
* **Hạn mức chi tiêu hàng tháng:** Cài đặt giới hạn ngân sách tối đa cho từng danh mục trong tháng.
* **Thanh tiến trình trực quan:** Hiển thị phần trăm đã chi tiêu, tự động đổi màu cảnh báo khi gần chạm hoặc vượt quá hạn mức cho phép.

### 4. 🔁 Khoản thu chi cố định (Recurring Transactions)
* **Đa dạng tần suất:** Thiết lập chu kỳ linh hoạt theo Ngày (Daily), Hàng tuần (Weekly), Hàng tháng (Monthly) hoặc Hàng năm (Yearly).
* **Tự động ghi nhận thông minh:** Ứng dụng tự động kiểm tra và ghi nhận các khoản thu chi đến ngày đáo hạn khi mở app, không sợ bị quên.
* **Linh hoạt quản lý:** Bật/tắt trạng thái tự động ghi nhận bất cứ lúc nào, hỗ trợ bộ nhớ đệm cục bộ ngoại tuyến.

### 5. 🔔 Nhắc nhở ghi chép hàng ngày (Daily Notifications)
* **Thông báo định kỳ:** Gửi thông báo nhắc nhở người dùng cập nhật sổ thu chi vào khung giờ đã thiết lập mỗi ngày qua `flutter_local_notifications`.
* **Trang cài đặt thông báo:** Tùy chọn giờ/phút nhắc nhở, bật/tắt dịch vụ và nút kiểm tra thông báo thử nghiệm trực tiếp.

### 6. 🔐 Xác thực & Bảo mật (Authentication)
* Đăng ký, đăng nhập an toàn thông qua **Supabase Authentication**.
* Tự động điều hướng và bảo vệ luồng truy cập với **GoRouter**.
* Tự động khôi phục phiên đăng nhập khi mở lại ứng dụng.

### 7. 🎨 Giao diện & Trải nghiệm (UI/UX)
* Thiết kế chuẩn **Material 3** với bảng màu Deep Purple gradient sang trọng, hiện đại.
* **Giao diện Đăng nhập / Đăng ký chuẩn Fintech:** Thiết kế Hero Header gradient, Form Card bo góc 24px, đổ bóng mềm mại cùng micro-animations.
* **Màn hình Splash khởi động:** Màn hình chào với logo thương hiệu và hiệu ứng chuyển trang êm ái.
* **Hiệu ứng chuyển động mượt mà:** Tích hợp `animate_do` (FadeInDown, FadeInUp, SlideIn).
* Thanh điều hướng đáy 4 tab tiện lợi: **Sổ chi tiêu**, **Thống kê**, **Danh mục**, **Cố định**.

### 8. ⚡ Tối ưu hóa hiệu năng & Khởi động tức thì (Performance & Cold Start)
* **Khởi động siêu tốc (Cold Start Optimization):** Tách biệt các dịch vụ nền tảng nặng (thông báo, timezone) chạy unawaited sau `runApp()`, giúp mở app tức thì dưới 0.5s.
* **Lazy Loading Navigation:** Chỉ nạp dữ liệu của Tab đang xem, giảm thiểu tải mạng đồng thời khi mở app.
* **Cơ chế Timeout chống treo:** Đảm bảo các truy vấn Supabase có thời hạn chờ rõ ràng (12 giây), tránh tình trạng màn hình xoay vô hạn khi mạng yếu.

### 9. 👤 Hồ sơ cá nhân (Profile & Customization)
* **Avatar & Ảnh bìa tùy biến:** Hỗ trợ tải lên ảnh tĩnh hoặc ảnh động GIF lưu trữ trên Supabase Storage bucket `Images`.
* **Thông tin cá nhân:** Tùy chỉnh Họ và tên, Số điện thoại, Địa chỉ và liên kết email tài khoản.
* **Đồng bộ tự động:** Dữ liệu hồ sơ đồng bộ trực tiếp với bảng `profiles` và tự động khởi tạo khi đăng ký tài khoản.

---

## 🏗️ Cấu trúc dự án (Clean Architecture)

```text
lib/
├── core/
│   ├── config/                           # Cấu hình URL & Key Supabase (SupabaseConfig)
│   ├── di/                               # Cấu hình Dependency Injection (GetIt, Injectable)
│   ├── error/                            # Định nghĩa Failure & Exception
│   ├── navigation/                       # Định tuyến điều hướng với GoRouter (AppRouter)
│   ├── services/                         # Dịch vụ thông báo (DailyReminderService) & UI cài đặt
│   ├── usecase/                          # Khung cơ sở UseCase
│   └── utils/                            # Helper xử lý icon, định dạng số, tiền tệ
│
├── features/
│   ├── auth/                             # Xác thực tài khoản (Login / Register Fintech UI)
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
│   ├── home/                             # Thanh điều hướng chính có Lazy Loading (MainNavigationPage)
│   │   └── presentation/pages/
│   │
│   ├── profile/                          # Hồ sơ cá nhân (Avatar, Ảnh bìa GIF/ảnh tĩnh, Thông tin)
│   │   ├── data/ (datasources, models)
│   │   └── presentation/pages/
│   │
│   ├── recurring/                        # Khoản thu chi cố định & định kỳ
│   │   ├── data/ (datasources, models)
│   │   ├── domain/ (entities)
│   │   └── presentation/ (pages)
│   │
│   └── splash/                           # Màn hình Splash kiểm tra phiên đăng nhập
│       └── presentation/pages/
│
└── main.dart                             # Điểm khởi chạy App & tối ưu hóa Cold Start
```

---

## 🛠️ Công nghệ & Thư viện sử dụng

| Thư viện | Phiên bản | Chức năng |
| :--- | :--- | :--- |
| `flutter_bloc` | `^8.1.6` | Quản lý trạng thái (State Management) theo chuẩn BLoC/Cubit |
| `supabase_flutter` | `^2.8.0` | Backend as a Service (Database PostgreSQL + Authentication + Storage) |
| `go_router` | `^14.2.0` | Quản lý điều hướng màn hình, Splash & bảo vệ route đăng nhập |
| `get_it` & `injectable` | `^7.7.0` / `^2.5.0` | Quản lý phụ thuộc (Dependency Injection) |
| `fl_chart` | `^0.70.1` | Vẽ biểu đồ tròn phân bổ & biểu đồ cột xu hướng 7 ngày |
| `animate_do` | `^3.3.4` | Hiệu ứng chuyển động (animations) mượt mà cho UI |
| `flutter_local_notifications` | `^17.2.2` | Quản lý và lập lịch thông báo nhắc nhở cục bộ |
| `timezone` | `^0.9.4` | Xử lý múi giờ cho thông báo định kỳ |
| `shared_preferences` | `^2.3.2` | Lưu trữ cấu hình cục bộ (cài đặt thông báo, cache khoản cố định) |
| `image_picker` | `^1.1.2` | Chọn ảnh/GIF từ thư viện để cập nhật hồ sơ |
| `intl` | `^0.20.2` | Định dạng tiền tệ VND (`₫`) và thời gian chuẩn Việt Nam |

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

-- 4. Bảng Profiles (Hồ sơ người dùng)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  phone TEXT,
  address TEXT,
  avatar_url TEXT,
  cover_url TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bật RLS cho profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON profiles FOR UPDATE USING (auth.uid() = id);

-- Trigger tự động tạo profile khi đăng ký tài khoản mới
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 5. Storage Bucket "Images" (Lưu Avatar và Ảnh bìa tĩnh / GIF)
INSERT INTO storage.buckets (id, name, public)
VALUES ('Images', 'Images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public Access Images"
ON storage.objects FOR SELECT
USING (bucket_id = 'Images');

CREATE POLICY "Allow authenticated uploads to Images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'Images');

CREATE POLICY "Allow authenticated updates in Images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'Images');

CREATE POLICY "Allow authenticated deletes in Images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'Images');
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
Mở file [`lib/core/config/supabase_config.dart`](file:///c:/Users/ACER/Android/flutter/Expense-Flutter/lib/core/config/supabase_config.dart) và cập nhật thông tin dự án Supabase của bạn:
```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_PROJECT_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 5. Chạy ứng dụng
```bash
flutter run
```

---

## 👨‍💻 Tác giả & Giấy phép

Được phát triển với ❤️ bằng **Flutter** & **Supabase**.
Mã nguồn mở phục vụ cho mục đích học tập và quản lý tài chính cá nhân.
