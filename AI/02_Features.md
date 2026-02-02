# Các Chức Năng Chính (Features)

## 1. Dashboard (Tổng Quan)
*   **Thẻ chỉ số tài chính:** Hiển thị Đầu kỳ, Cuối kỳ, Tổng Thu, Tổng Chi.
*   **Dòng tiền ròng (Net Flow):** Biểu đồ hoặc chỉ số thể hiện Thu - Chi.
*   **Ngân sách (Budgets):** Thanh tiến độ hiển thị tình hình chi tiêu theo ngân sách đã đặt.
*   **Giao dịch gần đây:** List 5 giao dịch mới nhất.
*   **Quick Action (Đi chợ nhanh):** Lối tắt để vào tính năng đi chợ nhanh.

## 2. Quản lý Giao Dịch (`Transactions`)
*   **Danh sách:** Xem lịch sử thu chi theo tháng.
*   **Thêm/Sửa/Xóa:** Ghi lại giao dịch với thông tin: Số tiền, Danh mục, Ghi chú, Ngày tháng, Người chi (Vợ/Chồng...), Tag (Cố định, Có hạn mức).
*   **Recurring (Định kỳ):** Tự động tạo giao dịch vào ngày 1 hàng tháng cho các khoản cố định (Điện, Nước, Lương...).

## 3. Ngân Sách (`Budgets`)
*   Thiết lập hạn mức chi tiêu cho từng danh mục (ví dụ: Ăn uống 5tr/tháng).
*   Cảnh báo khi chi tiêu vượt hạn mức (Màu sắc: Xanh -> Vàng -> Đỏ).
*   Xem số tiền còn lại của từng ngân sách (Available amount).

## 4. Báo Cáo (`Reports`)
*   **Biểu đồ tròn:** Cơ cấu chi tiêu theo danh mục.
*   **Biểu đồ cột:** Xu hướng chi tiêu theo ngày.
*   **So sánh:** Thu nhập vs Chi tiêu.

## 5. Cài đặt & Onboarding
*   **Onboarding:** Thiết lập số dư ban đầu khi lần đầu dùng app.
*   **Cài đặt chung:**
    *   Quản lý danh mục (Tuy nhiên Category hiện tại có vẻ migrate từ code cứng hoặc seed data).
    *   Cài đặt giao dịch định kỳ (Recurring).
    *   Reset dữ liệu (Vùng nguy hiểm).
    *   Theme/Giao diện (Dark/Light mode - đang phát triển).

## 6. Tính năng đặc biệt
*   **Đi chợ nhanh (Quick Shopping):**
    *   UI tối ưu cho việc chọn nhanh các mặt hàng thường mua (Rau, Thịt, Cá...).
    *   Tự động gom nhóm và tạo giao dịch.
*   **Tự động hóa đầu tháng:**
    *   Logic kiểm tra ngày đầu tháng để sinh giao dịch định kỳ (Logic nằm trong `main.dart` -> `ProcessRecurringTransactionsUseCase`).
