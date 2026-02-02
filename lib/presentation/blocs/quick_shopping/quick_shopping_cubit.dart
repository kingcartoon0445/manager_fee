import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/datasources/isar_service.dart';
import '../../../../data/models/quick_shopping_item_model.dart';
import 'package:isar/isar.dart';

// States
abstract class QuickShoppingState extends Equatable {
  const QuickShoppingState();
  @override
  List<Object> get props => [];
}

class QuickShoppingLoading extends QuickShoppingState {}

class QuickShoppingLoaded extends QuickShoppingState {
  final List<QuickShoppingItemModel> items;
  const QuickShoppingLoaded(this.items);
  @override
  List<Object> get props => [items];
}

class QuickShoppingError extends QuickShoppingState {
  final String message;
  const QuickShoppingError(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class QuickShoppingCubit extends Cubit<QuickShoppingState> {
  final IsarService isarService;

  QuickShoppingCubit(this.isarService) : super(QuickShoppingLoading());

  Future<void> loadItems() async {
    try {
      // Seed first if needed
      await isarService.seedQuickShoppingItemsIfNeeded();

      final isar = await isarService.db;
      final items = await isar.quickShoppingItemModels.where().findAll();
      emit(QuickShoppingLoaded(items));
    } catch (e) {
      emit(QuickShoppingError("Failed to load items: $e"));
    }
  }

  Future<void> addItem(QuickShoppingItemModel item) async {
    try {
      final isar = await isarService.db;
      await isar.writeTxn(() async {
        await isar.quickShoppingItemModels.put(item);
      });
      loadItems();
    } catch (e) {
      emit(QuickShoppingError("Failed to add item: $e"));
    }
  }

  Future<void> updateItem(QuickShoppingItemModel item) async {
    try {
      final isar = await isarService.db;
      await isar.writeTxn(() async {
        await isar.quickShoppingItemModels.put(item);
      });
      loadItems();
    } catch (e) {
      emit(QuickShoppingError("Failed to update item: $e"));
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      final isar = await isarService.db;
      await isar.writeTxn(() async {
        await isar.quickShoppingItemModels.delete(id);
      });
      loadItems();
    } catch (e) {
      emit(QuickShoppingError("Failed to delete item: $e"));
    }
  }
}
