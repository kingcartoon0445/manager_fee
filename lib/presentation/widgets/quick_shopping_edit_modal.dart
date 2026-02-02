import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peadget/core/app_colors.dart';
import '../../data/models/quick_shopping_item_model.dart';
import '../blocs/quick_shopping/quick_shopping_cubit.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class QuickShoppingEditModal extends StatelessWidget {
  const QuickShoppingEditModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<QuickShoppingCubit>()..loadItems(),
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chỉnh Sửa Danh Sách',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(),
              Expanded(
                child: BlocBuilder<QuickShoppingCubit, QuickShoppingState>(
                  builder: (context, state) {
                    if (state is QuickShoppingLoaded) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.items.length + 1, // +1 for Add button
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == state.items.length) {
                            return _buildAddButton(context);
                          }
                          final item = state.items[index];
                          return _buildItemCard(context, item);
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: () => _showEditor(context, null),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border:
              Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Colors.grey),
            SizedBox(width: 8),
            Text('Thêm mục mới', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, QuickShoppingItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(item.colorValue).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            IconData(item.iconCodePoint,
                fontFamily: item.iconFontFamily,
                fontPackage: item.iconFontPackage),
            color: Color(item.colorValue),
          ),
        ),
        title: Text(item.label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditor(context, item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, item),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, QuickShoppingItemModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa mục này?'),
        content: Text('Bạn có chắc muốn xóa "${item.label}" không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              context.read<QuickShoppingCubit>().deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditor(BuildContext context, QuickShoppingItemModel? item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditorSheet(
        item: item,
        onSave: (newItem) {
          if (item == null) {
            context.read<QuickShoppingCubit>().addItem(newItem);
          } else {
            // Copy ID to update
            newItem.id = item.id;
            context.read<QuickShoppingCubit>().updateItem(newItem);
          }
        },
      ),
    );
  }
}

class _EditorSheet extends StatefulWidget {
  final QuickShoppingItemModel? item;
  final Function(QuickShoppingItemModel) onSave;

  const _EditorSheet({this.item, required this.onSave});

  @override
  State<_EditorSheet> createState() => _EditorSheetState();
}

class _EditorSheetState extends State<_EditorSheet> {
  late TextEditingController _nameController;
  late int _selectedColor;
  late IconData _selectedIcon;

  // Predefined icons
  final List<IconData> _icons = [
    // Shopping & Store
    Icons.shopping_cart,
    Icons.shopping_bag,
    Icons.store,
    Icons.storefront,
    Icons.local_grocery_store,

    // Food & Dining
    Icons.fastfood,
    Icons.restaurant,
    Icons.restaurant_menu,
    Icons.dinner_dining,
    Icons.lunch_dining,
    Icons.breakfast_dining,
    Icons.brunch_dining,
    Icons.takeout_dining,

    // Drinks
    Icons.local_cafe,
    Icons.local_bar,
    Icons.coffee,
    Icons.coffee_maker,
    Icons.wine_bar,
    Icons.liquor,
    Icons.local_drink,
    Icons.water_drop,

    // Ingredients & Fresh
    Icons.egg,
    Icons.egg_alt,
    Icons.rice_bowl,
    Icons.soup_kitchen,
    Icons.cake,
    Icons.bakery_dining,
    Icons.icecream,
    Icons.local_pizza,
    Icons.set_meal,
    Icons.kebab_dining,
    Icons.tapas,
    Icons.bento,

    // Fruits & Veg (Using closely related icons as standard Material Icons are limited for specific fruits/veg)
    Icons.eco,
    Icons.grass,
    Icons.spa,
    Icons.agriculture,
    Icons.palette, // Often used for variety

    // Household & Appliances
    Icons.kitchen,
    Icons.blender,
    Icons.microwave,
    Icons.iron,
    Icons.cleaning_services,
    Icons.wash,
    Icons.soap,

    // Personal Care
    Icons.face,
    Icons.face_retouching_natural,
    Icons.medical_services,
    Icons.healing,
    Icons.sanitizer,

    // Pets
    Icons.pets,

    // Baby
    Icons.child_care,
    Icons.stroller,
    Icons.crib,

    // Others
    Icons.receipt,
    Icons.receipt_long,
    Icons.list,
    Icons.playlist_add_check,
    Icons.label,
    Icons.card_giftcard,
  ];

  final List<Color> _presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.label ?? '');
    _selectedColor = widget.item?.colorValue ?? Colors.blue.value;
    if (widget.item != null) {
      _selectedIcon = IconData(widget.item!.iconCodePoint,
          fontFamily: widget.item!.iconFontFamily,
          fontPackage: widget.item!.iconFontPackage);
    } else {
      _selectedIcon = Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Chi tiết mục',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Tên mục (Ví dụ: Trà sữa)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Chọn Biểu Tượng'),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: isSelected
                              ? Color(_selectedColor).withOpacity(0.2)
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Color(_selectedColor), width: 2)
                              : null),
                      child: Icon(icon,
                          color:
                              isSelected ? Color(_selectedColor) : Colors.grey),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Chọn Màu Sắc'),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: _presetColors.length + 1,
              itemBuilder: (context, index) {
                if (index == _presetColors.length) {
                  // "More" button
                  return InkWell(
                    onTap: () => _openAdvancedColorPicker(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.red,
                            Colors.green,
                            Colors.blue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  );
                }

                final color = _presetColors[index];
                final isSelected = color.value == _selectedColor;

                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color.value),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2.5)
                          : Border.all(color: Colors.grey[200]!),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) return;

                final newItem = QuickShoppingItemModel()
                  ..label = _nameController.text.trim()
                  ..iconCodePoint = _selectedIcon.codePoint
                  ..iconFontFamily = _selectedIcon.fontFamily
                  ..iconFontPackage = _selectedIcon.fontPackage
                  ..colorValue = _selectedColor
                  ..dbCategoryId = 2 // Default Food for now
                  ..note = 'Đi chợ: ${_nameController.text.trim()}';

                widget.onSave(newItem);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor:
                    AppColors.buttonEnabled, // Assuming standard blue
                foregroundColor: Colors.white,
              ),
              child: const Text('Lưu Thay Đổi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  void _openAdvancedColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn màu'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Color(_selectedColor),
              onColorChanged: (color) {
                setState(() => _selectedColor = color.value);
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Xong'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
