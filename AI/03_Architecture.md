# Kiến Trúc Dự Án (Architecture)

## 1. Clean Architecture
Dự án áp dụng mô hình Clean Architecture được chia thành 3 lớp chính:

### Presentation Layer (`lib/presentation`)
Chứa code giao diện và logic UI.
*   **Pages:** Các màn hình (Screens).
*   **Widgets:** Các thành phần UI tái sử dụng.
*   **BLoCs/Cubits:** Quản lý state của các màn hình (sử dụng thư viện `flutter_bloc`).
    *   `TransactionBloc`: Quản lý danh sách giao dịch, filtered list.
    *   `BudgetBloc`: Quản lý ngân sách.
    *   `ReportBloc`: Tính toán dữ liệu báo cáo.
    *   `ThemeCubit`: Quản lý giao diện sáng/tối.

### Domain Layer (`lib/domain`)
Chứa nghiệp vụ cốt lõi, không phụ thuộc vào framework hay database.
*   **Entities:** Core business objects (tương tự Models nhưng thuần Dart).
*   **UseCases:** Mỗi UseCase thực hiện một nhiệm vụ nghiệp vụ cụ thể (Ví dụ: `AddTransactionUseCase`, `CalculateMonthlyReportUseCase`).
*   **Repositories (Interfaces):** Định nghĩa các hành động lấy/ghi dữ liệu (Abstract classes).

### Data Layer (`lib/data`)
Thực thi các interface của Domain layer.
*   **Models:** Data models (Isar models), thường có phương thức `toEntity` và `fromEntity`.
*   **Datasources:** Làm việc trực tiếp với Isar Database.
*   **Repositories (Implementations):** Triển khai các interface Repository, gọi Datasource để lấy dữ liệu va map sang Entity.

## 2. Dependency Injection
Dùng `get_it` để quản lý dependencies. File cấu hình: `lib/injection_container.dart`.
Quy trình inject thường là:
Datasource -> Repository -> UseCase -> Bloc -> Base UI.

## 3. Luồng dữ liệu (Data Flow)
1.  **UI** gửi sự kiện (Event) tới **Bloc**.
2.  **Bloc** gọi **UseCase**.
3.  **UseCase** gọi **Repository (Interface)**.
4.  **Repository Impl** lấy dữ liệu từ **Datasource (Isar)**.
5.  Dữ liệu trả về ngược lại qua các lớp, map thành **Entity** và cuối cùng **Bloc** emit **State** mới ra UI.
