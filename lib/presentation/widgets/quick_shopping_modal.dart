import 'package:flutter/material.dart';
import 'quick_shopping_form.dart';

class QuickShoppingModal extends StatelessWidget {
  const QuickShoppingModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: QuickShoppingForm(
        onSuccess: () => Navigator.pop(context),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
