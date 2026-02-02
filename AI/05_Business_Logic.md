# Logic Nghiệp Vụ Phức Tạp (Business Logic)

## 1. Xử lý Giao Dịch Định Kỳ (`ProcessRecurringTransactionsUseCase`)
**Mục tiêu:** Tự động tạo giao dịch cho các khoản chi tiêu cố định (Recurring) vào đúng ngày đã cài đặt hàng tháng.

**Quy trình (`Main.dart` gọi khi khởi động):**
1.  **Kiểm tra Run lần đầu:**
    *   Sử dụng `SharedPreferences` key `initial_recurring_start_date`.
    *   Nếu là lần chạy đầu tiên (First run), lưu ngày hiện tại làm mốc. Không tạo giao dịch cho các ngày trong quá khứ của tháng đó (tránh spam giao dịch khi user mới cài app vào cuối tháng).
2.  **Lấy danh sách Recurring Config:** Load toàn bộ cấu hình từ `RecurringTransactionRepository`.
3.  **Lặp qua từng mục & Kiểm tra điều kiện:**
    *   **Ngày kích hoạt:** Nếu ngày cài đặt > số ngày của tháng hiện tại -> lấy ngày cuối tháng.
    *   **Quá khứ:** Chỉ tạo nếu ngày mục tiêu <= hôm nay.
    *   **Trùng lặp:** Kiểm tra trong tháng hiện tại đã có giao dịch nào trùng `categoryId`, `amount`, `type` và `day` chưa.
4.  **Tạo Giao dịch:** Nếu thỏa mãn và chưa tồn tại, tạo Transaction mới với tag `Phí định kỳ`.

## 2. Đi Chợ Nhanh (`Quick Shopping`)
**Mục tiêu:** Tối ưu thao tác ghi chép đi chợ hàng ngày.

**Dữ liệu (`QuickShoppingItemModel`):**
*   Lưu danh sách các mặt hàng thường mua (Thịt, Rau, Sữa...).
*   Mỗi item gắn sẵn với một `categoryId` (Ví dụ: Thịt -> Ăn uống).
*   Có màu sắc và icon riêng để hiển thị dạng lưới/grid.

**Luồng hoạt động:**
1.  Người dùng chọn các item trên UI (Grid).
2.  Nhập số tiền tổng hoặc chi tiết.
3.  Khi lưu, App sẽ tạo transaction tương ứng cho item đó, gom nhóm hoặc tạo lẻ tùy setting (hiện tại logic thêm từng item).
4.  **Seeding:** Khi mở App, `IsarService` sẽ tự động seed các item mặc định (Thịt cá, Rau củ, Trái cây...) nếu database trống.

## 3. Dự đoán Danh mục (`PredictCategoryUseCase`)
*(Tính năng này đang được phát triển hoặc sử dụng đơn giản)*
**Mục tiêu:** Gợi ý danh mục dựa trên mô tả hoặc thói quen cũ.
*   Hiện tại logic có thể dựa trên việc tìm kiếm các giao dịch cũ có cùng `note` hoặc logic AI đơn giản (nếu có tích hợp Google Generative AI như trong pubspec).
*   *Lưu ý:* `pubspec.yaml` có `google_generative_ai`, có thể tính năng này dùng Gemini API để phân loại giao dịch từ text/ảnh bill (OCR).

## 4. Reset Dữ Liệu (`ClearDataUseCase`)
**Mục tiêu:** Xóa sạch dữ liệu để bắt đầu lại (Vùng nguy hiểm).
**Thực hiện:**
*   Xóa toàn bộ: Transaction, MonthlyReport, Budget, RecurringModel, QuickShoppingItem.
*   **Giữ lại:** Category (Danh mục), AppSettings (Cấu hình).
