// lib/features/home/domain/entities/banner_entity.dart

class BannerEntity {
  final String id;
  final String imageUrl;
  final String? title;
  final String? description;

  BannerEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
  });
}