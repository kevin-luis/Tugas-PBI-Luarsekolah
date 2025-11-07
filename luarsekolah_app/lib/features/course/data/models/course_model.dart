import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.name,
    required super.price,
    required super.category,
    super.thumbnail,
    super.rating,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  // From API JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    String category = '';
    
    if (json['categoryTag'] != null && json['categoryTag'] is List) {
      final tags = json['categoryTag'] as List;
      if (tags.isNotEmpty) {
        category = tags[0].toString();
        if (category.isNotEmpty) {
          category = category[0].toUpperCase() + category.substring(1);
        }
      }
    }

    double price = 0.0;
    if (json['price'] != null) {
      if (json['price'] is String) {
        final cleanPrice = json['price'].toString().replaceAll(RegExp(r'[^\d.]'), '');
        price = double.tryParse(cleanPrice) ?? 0.0;
      } else if (json['price'] is num) {
        price = json['price'].toDouble();
      }
    }

    return CourseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: price,
      category: category,
      thumbnail: json['thumbnail']?.toString(),
      rating: json['rating']?.toString(),
      createdBy: json['createdBy']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  // To API JSON
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'price': price.toStringAsFixed(2),
    };

    if (category.isNotEmpty) {
      map['categoryTag'] = [category.toLowerCase()];
    }

    if (thumbnail != null && thumbnail!.isNotEmpty) {
      map['thumbnail'] = thumbnail;
    }
    
    if (rating != null && rating!.isNotEmpty) {
      map['rating'] = rating;
    }

    if (createdBy != null && createdBy!.isNotEmpty) {
      map['createdBy'] = createdBy;
    }

    return map;
  }

  // Convert Entity to Model
  factory CourseModel.fromEntity(CourseEntity entity) {
    return CourseModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      category: entity.category,
      thumbnail: entity.thumbnail,
      rating: entity.rating,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Convert Model to Entity
  CourseEntity toEntity() {
    return CourseEntity(
      id: id,
      name: name,
      price: price,
      category: category,
      thumbnail: thumbnail,
      rating: rating,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}