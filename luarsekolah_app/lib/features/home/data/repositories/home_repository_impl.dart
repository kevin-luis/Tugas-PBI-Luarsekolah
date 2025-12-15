// lib/features/home/data/repositories/home_repository_impl.dart

import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/program_menu_entity.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BannerEntity>> getBanners() async {
    try {
      return await remoteDataSource.getBanners();
    } catch (e) {
      throw Exception('Failed to get banners: $e');
    }
  }

  @override
  Future<List<ProgramMenuEntity>> getPrograms() async {
    try {
      return await remoteDataSource.getPrograms();
    } catch (e) {
      throw Exception('Failed to get programs: $e');
    }
  }

  @override
  Future<List<ClassEntity>> getPopularClasses() async {
    try {
      return await remoteDataSource.getPopularClasses();
    } catch (e) {
      throw Exception('Failed to get popular classes: $e');
    }
  }

  @override
  Future<List<SubscriptionEntity>> getSubscriptions() async {
    try {
      return await remoteDataSource.getSubscriptions();
    } catch (e) {
      throw Exception('Failed to get subscriptions: $e');
    }
  }
}