// lib/features/home/domain/repositories/home_repository.dart

import 'package:luarsekolah_app/features/home/domain/entities/banner_entity.dart';
import 'package:luarsekolah_app/features/home/domain/entities/program_menu_entity.dart';
import 'package:luarsekolah_app/features/home/domain/entities/class_entity.dart';
import 'package:luarsekolah_app/features/home/domain/entities/subscription_entity.dart';

abstract class HomeRepository {
  Future<List<BannerEntity>> getBanners();
  Future<List<ProgramMenuEntity>> getPrograms();
  Future<List<ClassEntity>> getPopularClasses();
  Future<List<SubscriptionEntity>> getSubscriptions();
}