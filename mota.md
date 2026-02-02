1. TỔNG QUAN HỆ THỐNG
Ứng dụng được thiết kế dành cho các hộ gia đình để theo dõi dòng tiền, kiểm soát ngân sách và báo cáo tài chính. Ứng dụng hoạt động hoàn toàn Offline (lưu dữ liệu trên trình duyệt của người dùng), không cần kết nối internet để ghi chép.
2. CÁC MODULE CHỨC NĂNG CHÍNH
A. Màn hình Tổng Quan (Dashboard)
Đây là màn hình chính giúp người dùng nắm bắt tình hình tài chính ngay lập tức.
Thẻ chỉ số tài chính: Hiển thị 4 thông số quan trọng:
Đầu kỳ: Số dư mang sang từ tháng trước + Số dư khởi tạo.
Cuối kỳ: Số tiền thực tế còn lại hiện tại.
Tổng Thu: Tổng tiền kiếm được trong tháng.
Tổng Chi: Tổng tiền đã tiêu trong tháng.
Đi chợ nhanh (Quick Action): Nút tắt lớn giúp truy cập nhanh tính năng ghi chép đi chợ hàng ngày.
Chỉ số Dòng tiền ròng (Net Flow): Hiển thị chênh lệch (Thu - Chi). Màu xanh nếu dương (tiết kiệm), màu đỏ nếu âm (thâm hụt).
Theo dõi Hạn mức (Budgets): Hiển thị các thanh tiến độ cho các khoản ngân sách đã cài đặt (Ví dụ: Tiền ăn 5 triệu).
Báo màu xanh/vàng/đỏ tùy theo mức độ tiêu dùng.
Hiển thị số tiền còn lại hoặc số tiền đã vượt quá.
Giao dịch gần đây: Liệt kê 5 giao dịch mới nhất.
B. Sổ Giao Dịch (Transactions)
Danh sách: Hiển thị toàn bộ lịch sử thu/chi trong tháng được chọn.
Thông tin chi tiết: Mỗi dòng hiển thị Icon danh mục, tên danh mục, ghi chú, người chi, ngày tháng và số tiền.
Phân loại:
Giao dịch thường.
Giao dịch cố định (Có tag "Cố định").
Giao dịch thuộc hạn mức (Có tag "Có hạn mức").
Thao tác: Cho phép xóa giao dịch sai.
C. Báo Cáo & Biểu Đồ (Reports)
Biểu đồ tròn (Pie Chart): Phân tích cơ cấu chi tiêu. Cho biết hạng mục nào (Ăn uống, Mua sắm...) chiếm tỷ trọng lớn nhất.
Biểu đồ cột (Bar Chart): Xu hướng chi tiêu theo ngày (Từ ngày 1 đến cuối tháng) để phát hiện các ngày tiêu xài bất thường.
D. Cài Đặt (Settings)
Trung tâm quản lý cấu hình của ứng dụng:
Số dư khởi tạo: Thiết lập số tiền ban đầu khi mới dùng app.
Quản lý Hạn mức (Budgets):
Tạo ví ngân sách (Ví dụ: "Tiền xăng", "Sinh hoạt phí").
Đặt giới hạn tiền tối đa cho ví đó.
Xem danh sách và xóa các hạn mức cũ.
Thu Chi Cố Định (Recurring Items):
Cài đặt các khoản tự động lặp lại hàng tháng (Tiền nhà, Lương cứng, Tiền mạng...).
Hệ thống tự động tạo giao dịch vào ngày 01 hàng tháng dựa trên danh sách này.
Vùng nguy hiểm: Chức năng "Reset dữ liệu" để xóa sạch toàn bộ thông tin và đưa app về trạng thái ban đầu.
3. CÁC TÍNH NĂNG NGHIỆP VỤ ĐẶC BIỆT
A. Tính năng "Đi Chợ Nhanh"
Mục đích: Giảm thao tác nhập liệu cho việc đi chợ hàng ngày (chiếm 60-70% số lần mở app).
Cách hoạt động:
Bấm nút "Đi Chợ Hôm Nay?".
Chọn mặt hàng (Thịt cá, Rau củ, Trái cây, Sữa...).
Nhập số tiền và Lưu.
Tự động hóa: Hệ thống tự điền Danh mục, Ngày giờ, Người chi (mặc định là Vợ) và Ghi chú tương ứng.
B. Tính năng "Hạn Mức Chi Tiêu" (Budgets)
Logic: Khi thêm một giao dịch Chi tiêu, người dùng có thể chọn "Trừ vào hạn mức".
Hiển thị: Ngay trong lúc chọn, app sẽ hiện số tiền còn lại của hạn mức đó (Ví dụ: "Còn lại: 500.000đ").
Báo cáo: Tại Dashboard, thanh tiến độ sẽ chạy dựa trên tổng các giao dịch gán với hạn mức đó.
C. Tính năng "Tự Động Hóa Đầu Tháng"
Mỗi khi người dùng mở app hoặc chuyển sang tháng mới, hệ thống sẽ kiểm tra:
Tháng này đã có dữ liệu chưa?
Nếu chưa: Tự động quét danh sách "Thu Chi Cố Định" và tạo hàng loạt giao dịch cho ngày 01 của tháng đó.
Giúp người dùng không phải nhập tay tiền điện, tiền nhà, lương mỗi tháng.