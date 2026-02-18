import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyConsentDialog extends StatelessWidget {
  const PrivacyConsentDialog({super.key});

  Future<void> _launchPrivacyPolicy() async {
    // Replace with your actual privacy policy URL
    final Uri url = Uri.parse('https://your-privacy-policy-url.com');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.privacy_tip_outlined, color: AppColors.primaryBlue),
          SizedBox(width: 8),
          Expanded(child: Text('Quyền Riêng Tư & AI')),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text(
              'Để hỗ trợ bạn nhập liệu nhanh chóng, tính năng này sử dụng dịch vụ AI của bên thứ ba (Google Gemini).',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dữ liệu nào sẽ được gửi đi?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('• Nội dung tin nhắn bạn nhập.'),
            const Text('• Hình ảnh hóa đơn mà bạn chọn.'),
            const SizedBox(height: 16),
            const Text(
              'Mục đích:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
                'Dữ liệu này chỉ được sử dụng để trích xuất thông tin giao dịch (số tiền, danh mục, ghi chú) và không được sử dụng cho mục đích khác.'),
            const SizedBox(height: 16),
            // InkWell(
            //   onTap: _launchPrivacyPolicy,
            //   child: const Text(
            //     'Xem Chính sách Quyền riêng tư',
            //     style: TextStyle(
            //       color: Colors.blue,
            //       decoration: TextDecoration.underline,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        FilledButton(
          child: const Text('Cho phép'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
