// lib/features/home/domain/repositories/home_repository.dart

import '../entities/banner_entity.dart';
import '../entities/program_menu_entity.dart';
import '../entities/class_entity.dart';
import '../entities/subscription_entity.dart';

abstract class HomeRepository {
  Future<List<BannerEntity>> getBanners();
  Future<List<ProgramMenuEntity>> getPrograms();
  Future<List<ClassEntity>> getPopularClasses();
  Future<List<SubscriptionEntity>> getSubscriptions();
}