class FoodModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final int deliveryTime;
  final String category;
  final bool isFavorite;
  final List<String> extras;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.deliveryTime,
    required this.category,
    this.isFavorite = false,
    this.extras = const [],
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      deliveryTime: json['deliveryTime'] as int? ?? 30,
      category: json['category'] ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
      extras: json['extras'] != null ? List<String>.from(json['extras']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'category': category,
      'isFavorite': isFavorite,
      'extras': extras,
    };
  }

  FoodModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    double? rating,
    int? deliveryTime,
    String? category,
    bool? isFavorite,
    List<String>? extras,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      extras: extras ?? this.extras,
    );
  }
}
