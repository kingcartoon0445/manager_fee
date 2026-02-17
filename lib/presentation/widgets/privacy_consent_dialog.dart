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
          Expanded(child: Text('Quy&#x1EC1;n Ri&#xEA;ng T&#x1B0; & AI')),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text(
              'Đ&#x1EC3; h&#x1ED7; tr&#x1EE3; b&#x1EA1;n nh&#x1EAD;p li&#x1EC7;u nhanh ch&#x00F3;ng, t&#x00ED;nh n&#x0103;ng n&#x00E0;y s&#x1EED; d&#x1EE5;ng d&#x1ECB;ch v&#x1EE5; AI c&#x1EE7;a b&#x00EA;n th&#x1EE9; ba (Google Gemini).',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'D&#x1EFF; li&#x1EC7;u n&#x00E0;o s&#x1EBD; &#x0111;&#x01B0;&#x1EE3;c g&#x1EED;i &#x0111;i?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
                '• N&#x1ED9;i dung tin nh&#x1EAF;n b&#x1EA1;n nh&#x1EAD;p.'),
            const Text(
                '• H&#x00EC;nh &#x1EA3;nh h&#x00F3;a &#x0111;&#x01A1;n m&#x00E0; b&#x1EA1;n ch&#x1ECD;n.'),
            const SizedBox(height: 16),
            const Text(
              'M&#x1EE5;c &#x0111;&#x00ED;ch:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
                'D&#x1EEF; li&#x1EC7;u n&#x00E0;y ch&#x1EC9; &#x0111;&#x01B0;&#x1EE3;c s&#x1EED; d&#x1EE5;ng &#x0111;&#x1EC3; tr&#x00ED;ch xu&#x1EA5;t th&#x00F4;ng tin giao d&#x1ECB;ch (s&#x1ED1; ti&#x1EC1;n, danh m&#x1EE5;c, ghi ch&#x00FA;) v&#x00E0; kh&#x00F4;ng &#x0111;&#x01B0;&#x1EE3;c s&#x1EED; d&#x1EE5;ng cho m&#x1EE5;c &#x0111;&#x00ED;ch kh&#x00E1;c.'),
            const SizedBox(height: 16),
            InkWell(
              onTap: _launchPrivacyPolicy,
              child: const Text(
                'Xem Ch&#x00ED;nh s&#x00E1;ch Quy&#x1EC1;n ri&#x00EA;ng t&#x01B0;',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('&#x0110;&#x1EC3; sau',
              style: TextStyle(color: Colors.grey)),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        FilledButton(
          child: const Text('Cho ph&#x00E9;p'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
