class ClassModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? thumbnail;
  final String? rating;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;

  ClassModel({
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

  // From API JSON (response dari API)
  factory ClassModel.fromApiJson(Map<String, dynamic> json) {
    // Parse categoryTag dari array ke string tunggal
    String category = ''; // Default kosong untuk handle empty categoryTag
    
    if (json['categoryTag'] != null && json['categoryTag'] is List) {
      final tags = json['categoryTag'] as List;
      if (tags.isNotEmpty) {
        category = tags[0].toString();
        // Capitalize first letter
        if (category.isNotEmpty) {
          category = category[0].toUpperCase() + category.substring(1);
        }
      }
    }

    // Parse price dari string/number ke double
    double price = 0.0;
    if (json['price'] != null) {
      if (json['price'] is String) {
        // Remove any formatting and parse
        final cleanPrice = json['price'].toString().replaceAll(RegExp(r'[^\d.]'), '');
        price = double.tryParse(cleanPrice) ?? 0.0;
      } else if (json['price'] is num) {
        price = json['price'].toDouble();
      }
    }

    return ClassModel(
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

  // To API JSON (untuk create/update ke API)
  Map<String, dynamic> toApiJson() {
    final map = <String, dynamic>{
      'name': name,
      'price': price.toStringAsFixed(2),
    };

    // Only add categoryTag if not empty
    if (category.isNotEmpty) {
      map['categoryTag'] = [category.toLowerCase()];
    }

    if (thumbnail != null && thumbnail!.isNotEmpty) {
      map['thumbnail'] = thumbnail;
    }
    
    if (rating != null && rating!.isNotEmpty) {
      map['rating'] = rating;
    }

    return map;
  }

  // From local JSON (untuk SharedPreferences - backward compatibility)
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString(),
      rating: json['rating']?.toString(),
    );
  }

  // To local JSON (untuk SharedPreferences - backward compatibility)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (rating != null) 'rating': rating,
    };
  }

  ClassModel copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? thumbnail,
    String? rating,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      thumbnail: thumbnail ?? this.thumbnail,
      rating: rating ?? this.rating,
    );
  }

  static ClassModel empty() {
    return ClassModel(
      id: '',
      name: '',
      price: 0.0,
      category: '',
    );
  }
}