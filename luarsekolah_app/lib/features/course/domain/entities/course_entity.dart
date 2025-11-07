class CourseEntity {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? thumbnail;
  final String? rating;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;

  const CourseEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.thumbnail,
    this.rating,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  CourseEntity copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? thumbnail,
    String? rating,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return CourseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      thumbnail: thumbnail ?? this.thumbnail,
      rating: rating ?? this.rating,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static CourseEntity empty() {
    return const CourseEntity(
      id: '',
      name: '',
      price: 0.0,
      category: '',
    );
  }
}