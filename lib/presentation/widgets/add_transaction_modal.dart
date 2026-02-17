import 'package:flutter/material.dart';
import 'add_transaction_form.dart';

class AddTransactionModal extends StatelessWidget {
  final double? initialAmount;
  final String? initialNote;
  final DateTime? initialDate;

  const AddTransactionModal({
    super.key,
    this.initialAmount,
    this.initialNote,
    this.initialDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Thêm Giao Dịch Mới',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Form
            Expanded(
              child: AddTransactionForm(
                initialAmount: initialAmount,
                initialNote: initialNote,
                initialDate: initialDate,
                onSuccess: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
