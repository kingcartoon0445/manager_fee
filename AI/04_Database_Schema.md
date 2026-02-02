# Cấu Trúc Cơ Sở Dữ Liệu (Isar Schema)

## 1. TransactionModel (`Transaction_Collection`)
Lưu trữ các giao dịch thu chi.
*   `id`: Id (AutoIncrement)
*   `amount`: double (Số tiền)
*   `type`: TransactionType (Income/Expense - Enum ord 0/1)
*   `categoryId`: int (Liên kết với Category)
*   `date`: DateTime (Ngày giao dịch)
*   `note`: String? (Ghi chú)
*   `memberId`: String? (Người chi, vd: "Husband", "Wife")
*   `tags`: List<String>? (Tag phụ, vd: "fixed", "budget_tracked")
*   `budgetId`: int? (Liên kết với Budget nếu có)

## 2. CategoryModel (`Category_Collection`)
Danh mục thu chi.
*   `id`: Id
*   `name`: String (Tên danh mục)
*   `type`: TransactionType (Income/Expense)
*   `icon`: String? (Tên icon asset hoặc mã icon)
*   `parentId`: int? (Cho danh mục con - chưa thấy sử dụng nhiều)

## 3. BudgetModel (`Budget_Collection`)
Ngân sách chi tiêu.
*   `id`: Id
*   `name`: String
*   `amount`: double (Hạn mức)
*   `categoryId`: int? (Áp dụng cho danh mục nào, null = chung?)
*   `startDate`: DateTime
*   `endDate`: DateTime

## 4. RecurringTransactionModel (`Recurring_Collection`)
Giao dịch định kỳ tự động.
*   `id`: Id
*   `amount`: double
*   `note`: String
*   `categoryId`: int
*   `type`: TransactionType
*   `frequency`: Enum (Monthly, Weekly... - Cần check code)
*   `executionDay`: int (Ngày thực hiện, vd: ngày 1)

## 5. AppSettingsModel & Khác
*   `AppSettings`: Lưu trạng thái onboarding, theme preferences.
*   `QuickShoppingItem`: (Nếu có) Lưu cấu hình các món đồ hay mua.
