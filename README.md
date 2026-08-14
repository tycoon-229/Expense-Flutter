# 💰 Expense Tracker App

Ứng dụng quản lý chi tiêu đơn giản được xây dựng bằng **Flutter**, áp dụng kiến trúc **Clean Architecture** và các công nghệ hiện đại để quản lý trạng thái, lưu trữ dữ liệu, điều hướng và hiển thị biểu đồ.

## ✨ Tổng quan

**Expense Tracker App** hỗ trợ người dùng quản lý các khoản chi tiêu cá nhân một cách đơn giản và trực quan.

Ứng dụng cung cấp các chức năng chính:

* 📊 Xem tổng quan các khoản chi tiêu.
* 🥧 Hiển thị biểu đồ phân bổ chi tiêu theo danh mục.
* ➕ Thêm khoản chi tiêu mới.
* 🗑️ Xóa khoản chi tiêu bằng thao tác vuốt.
* 💾 Lưu trữ dữ liệu trực tiếp trên thiết bị.
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
│   └── usecase/
│
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

### Core

Chứa các thành phần dùng chung cho toàn bộ ứng dụng:

* Dependency Injection với `get_it`.
* Error handling.
* Base UseCase.

### Data

Chịu trách nhiệm xử lý và lưu trữ dữ liệu.

Ứng dụng sử dụng **Hive** làm cơ sở dữ liệu local để lưu các khoản chi tiêu trên thiết bị.

### Domain

Chứa **Business Logic** của ứng dụng, bao gồm:

* Entities.
* Repository interfaces.
* UseCases.

Tầng Domain không phụ thuộc trực tiếp vào giao diện người dùng hoặc công nghệ lưu trữ dữ liệu.

### Presentation

Chịu trách nhiệm hiển thị giao diện và quản lý trạng thái ứng dụng.

Bao gồm:

* BLoC.
* Pages.
* Widgets.

---

## 🎨 Giao diện & Hiệu ứng

### Material 3

Ứng dụng sử dụng **Material 3** để xây dựng giao diện hiện đại và nhất quán.

### Animations

Thư viện `animate_do` được sử dụng để tạo hiệu ứng xuất hiện cho danh sách các khoản chi tiêu.

### Charts

Thư viện `fl_chart` được sử dụng để xây dựng biểu đồ tròn, giúp người dùng trực quan hóa tỷ lệ chi tiêu theo từng danh mục.

---

## 🛠️ Công nghệ & Thư viện

| Thư viện       | Chức năng                            |
| -------------- | ------------------------------------ |
| `flutter_bloc` | Quản lý trạng thái ứng dụng          |
| `get_it`       | Dependency Injection                 |
| `injectable`   | Hỗ trợ cấu hình Dependency Injection |
| `hive_flutter` | Lưu trữ dữ liệu local                |
| `fl_chart`     | Hiển thị biểu đồ chi tiêu            |
| `animate_do`   | Tạo hiệu ứng chuyển động             |
| Flutter        | Framework phát triển ứng dụng        |

---

## 📱 Các màn hình & Tính năng

### 1. 📊 Danh sách chi tiêu

Màn hình chính cung cấp cái nhìn tổng quan về tình hình chi tiêu.

Bao gồm:

* Biểu đồ tròn phân bổ chi tiêu theo danh mục.
* Danh sách các khoản chi tiêu.
* Thông tin chi tiết của từng khoản chi tiêu.

---

### 2. ➕ Thêm chi tiêu

Người dùng có thể thêm một khoản chi tiêu mới thông qua Dialog.

Thông tin cần nhập:

* Tên khoản chi tiêu.
* Số tiền.
* Danh mục chi tiêu.

Sau khi thêm, khoản chi tiêu sẽ được lưu vào cơ sở dữ liệu local.

---

### 3. 🗑️ Xóa chi tiêu

Người dùng có thể xóa một khoản chi tiêu bằng thao tác **Swipe to Dismiss**.

```text
Vuốt khoản chi tiêu
        ↓
Xóa khoản chi tiêu
        ↓
Cập nhật danh sách
```

---

## 🔄 Luồng hoạt động

```text
┌──────────────────────┐
│   Expense Tracker    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Danh sách chi tiêu   │
└──────────┬───────────┘
           │
     ┌─────┴─────┐
     │           │
     ▼           ▼
  Thêm mới      Xóa
     │           │
     ▼           ▼
   Dialog    Swipe Dismiss
     │
     ▼
  Hive Local
     │
     ▼
 Cập nhật BLoC
     │
     ▼
 Cập nhật UI
```

---

## 📂 Clean Architecture Flow

Luồng xử lý dữ liệu trong ứng dụng:

```text
Presentation
     │
     ▼
   BLoC
     │
     ▼
  UseCase
     │
     ▼
Repository Interface
     │
     ▼
Repository Implementation
     │
     ▼
Hive Local Database
```

Cách tổ chức này giúp các thành phần được phân tách rõ ràng và dễ bảo trì.

---

## 🚀 Hướng dẫn chạy ứng dụng

### 1. Cài đặt Flutter

Đảm bảo máy tính đã cài đặt **Flutter** và Flutter SDK hoạt động bình thường.

Kiểm tra bằng:

```bash
flutter doctor
```

---

### 2. Clone project

```bash
git clone <repository-url>
```

Di chuyển vào thư mục project:

```bash
cd expense_tracker
```

---

### 3. Cài đặt dependencies

Chạy:

```bash
flutter pub get
```

---

### 4. Chạy ứng dụng

```bash
flutter run
```

Flutter sẽ build và chạy ứng dụng trên thiết bị hoặc emulator đang được kết nối.

---

## 📋 Yêu cầu môi trường

Trước khi chạy project, cần có:

* Flutter SDK.
* Dart SDK đi kèm Flutter.
* Android Studio hoặc môi trường phát triển Flutter tương đương.
* Android Emulator hoặc thiết bị Android để chạy ứng dụng.

---

## 🎯 Mục tiêu của Project

Project được xây dựng nhằm minh họa việc phát triển một ứng dụng Flutter có cấu trúc rõ ràng bằng **Clean Architecture**, đồng thời áp dụng:

* State Management với BLoC.
* Dependency Injection.
* Local Database.
* Navigation.
* Data Visualization.
* UI Animation.
* Material 3.

---

## 👨‍💻 Author

**Expense Tracker App**

Built with ❤️ using Flutter.
