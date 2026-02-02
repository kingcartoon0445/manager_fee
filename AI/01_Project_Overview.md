# Tổng Quan Dự Án Manager Fee (Peadget)

## 1. Giới thiệu
Manager Fee (tên gói: Peadget) là ứng dụng quản lý chi tiêu cá nhân/gia đình, tập trung vào sự đơn giản, hoạt động offline và hỗ trợ đầy đủ các tính năng quản lý tài chính cơ bản.

## 2. Công nghệ sử dụng
*   **Ngôn ngữ:** Dart (SDK >=3.0.0 <4.0.0)
*   **Framework:** Flutter
*   **Kiến trúc:** Clean Architecture (Presentation, Domain, Data)
*   **State Management:** BLoC (flutter_bloc 9.1.1)
*   **Cơ sở dữ liệu:** Isar (3.1.0) - NoSQL, Offline-first
*   **Dependency Injection:** GetIt (9.2.0)
*   **Biểu đồ:** fl_chart (0.66.0)
*   **Khác:**
    *   `intl`: Định dạng ngày tháng, tiền tệ.
    *   `google_fonts`: Font chữ (Inter).
    *   `flutter_local_notifications`: Thông báo định kỳ.

## 3. Cấu trúc thư mục cấp cao
```
lib/
├── core/           # Tiện ích chung, hằng số, extension
├── data/           # Layer Data: Models, Datasources, Repositories Impl
├── domain/         # Layer Domain: Entities, Usecases, Repository Interfaces
├── presentation/   # Layer Presentation: Pages, Widgets, BLoCs
├── injection_container.dart # Cấu hình Dependency Injection
└── main.dart       # Entry point
```

## 4. Quy ước Code
*   Sử dụng **Clean Architecture** để tách biệt các lớp.
*   Model trong `data` map với Entity trong `domain`.
*   Sử dụng `Either` (dartz hoặc tự định nghĩa) cho xử lý lỗi (cần kiểm tra kỹ implementation thực tế).
*   Ngôn ngữ UI: Tiếng Việt (`vi_VN`).
