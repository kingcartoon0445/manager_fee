import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final int type; // 0: Income, 1: Expense
  final String? icon;
  final int? parentId;
  final int? colorValue;

  const Category({
    this.id,
    required this.name,
    required this.type,
    this.icon,
    this.parentId,
    this.colorValue,
  });

  @override
  List<Object?> get props => [id, name, type, icon, parentId, colorValue];
}
