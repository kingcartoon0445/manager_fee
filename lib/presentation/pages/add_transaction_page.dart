import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart' as entity;
import '../../domain/entities/category.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int _selectedType = 1; // 0: Income, 1: Expense (Default)
  DateTime _selectedDate = DateTime.now();
  int _selectedCategoryId =
      0; // Temporary logic, should select from Category List

  // Mock categories for now until CategoryBloc is ready
  final List<Category> _categories = [
    const Category(id: 1, name: 'Ăn uống', type: 1, icon: 'restaurant'),
    const Category(id: 2, name: 'Di chuyển', type: 1, icon: 'directions_car'),
    const Category(id: 3, name: 'Lương', type: 0, icon: 'attach_money'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Giao Dịch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                suffixText: 'đ',
              ),
            ),
            const SizedBox(height: 20),

            // Type Toggle
            ToggleButtons(
              isSelected: [_selectedType == 0, _selectedType == 1],
              onPressed: (index) {
                setState(() {
                  _selectedType = index;
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Thu nhập'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Chi tiêu'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date Picker
            ListTile(
              title: Text(
                'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),

            // Category Selector (Mock)
            DropdownButtonFormField<int>(
              value: _categories
                  .firstWhere(
                    (e) => e.type == _selectedType,
                    orElse: () => _categories[0],
                  )
                  .id, // Simple logic
              items: _categories.where((e) => e.type == _selectedType).map((e) {
                return DropdownMenuItem(
                  value: e.id,
                  child: Row(
                    children: [
                      Icon(e.type == 0 ? Icons.attach_money : Icons.money_off),
                      const SizedBox(width: 10),
                      Text(e.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedCategoryId = val ?? 0);
              },
              decoration: const InputDecoration(labelText: 'Danh mục'),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0;
                if (amount <= 0) return;

                final transaction = entity.Transaction(
                  amount: amount,
                  type: _selectedType,
                  categoryId: _selectedCategoryId,
                  date: _selectedDate,
                  note: _noteController.text,
                );

                context.read<TransactionBloc>().add(
                  AddTransactionEvent(transaction),
                );
                Navigator.pop(context);
              },
              child: const Text('Lưu Giao Dịch'),
            ),
          ],
        ),
      ),
    );
  }
}
