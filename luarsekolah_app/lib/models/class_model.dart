class ClassModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? thumbnail;

  ClassModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.thumbnail,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'thumbnail': thumbnail,
    };
  }

  // Create from JSON
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  // Create empty instance
  factory ClassModel.empty() {
    return ClassModel(
      id: '',
      name: '',
      price: 0.0,
      category: '',
      thumbnail: null,
    );
  }

  // Copy with
  ClassModel copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? thumbnail,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}