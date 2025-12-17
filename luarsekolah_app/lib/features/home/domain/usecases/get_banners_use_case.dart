// lib/features/home/domain/usecases/get_banners_use_case.dart

import 'package:luarsekolah_app/features/home/domain/entities/banner_entity.dart';
import 'package:luarsekolah_app/features/home/domain/repositories/home_repository.dart';

class GetBannersUseCase {
  final HomeRepository repository;

  GetBannersUseCase(this.repository);

  Future<List<BannerEntity>> call() async {
    return await repository.getBanners();
  }
}