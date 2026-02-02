import '../../domain/usecases/clear_data_usecase.dart';
import '../datasources/isar_service.dart';

class AdminRepositoryImpl implements AdminRepository {
  final IsarService isarService;

  AdminRepositoryImpl(this.isarService);

  @override
  Future<void> clearAllData() async {
    await isarService.cleanDb();
  }
}
