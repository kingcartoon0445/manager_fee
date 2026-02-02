import 'package:peadget/core/category_icons.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
// import '../core/category_icons.dart';

/// Helper widget to display category avatar with icon and color
/// Uses emoji from database if available, otherwise falls back to Material icons
class CategoryAvatar extends StatelessWidget {
  final Category? category;
  final int? categoryId;
  final double size;
  final double iconSize;

  const CategoryAvatar({
    super.key,
    this.category,
    this.categoryId,
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    // Get color based on categoryId
    final id = category?.id ?? categoryId ?? 0;
    final color = Colors.primaries[id % Colors.primaries.length];

    // Get icon - prefer emoji from category, fallback to Material icon
    Widget iconWidget;
    if (category?.icon != null && category!.icon!.isNotEmpty) {
      // Use emoji from database
      iconWidget = Text(
        category!.icon!,
        style: TextStyle(fontSize: iconSize),
      );
    } else {
      // Fallback to Material icon from CategoryIcons
      final catInfo = CategoryIcons.getCategoryById(id);
      iconWidget = Icon(
        catInfo['icon'] as IconData,
        color: catInfo['color'] as Color,
        size: iconSize,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: size > 50 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: size > 50 ? BorderRadius.circular(12) : null,
      ),
      child: Center(child: iconWidget),
    );
  }
}

/// Helper to get category color by ID
Color getCategoryColor(int categoryId) {
  return Colors.primaries[categoryId % Colors.primaries.length];
}

/// Helper to get category icon widget
Widget getCategoryIcon(Category? category, {double size = 20}) {
  if (category?.icon != null && category!.icon!.isNotEmpty) {
    return Text(category.icon!, style: TextStyle(fontSize: size));
  }

  final catInfo = CategoryIcons.getCategoryById(category?.id ?? 0);
  return Icon(
    catInfo['icon'] as IconData,
    size: size,
    color: catInfo['color'] as Color,
  );
}
