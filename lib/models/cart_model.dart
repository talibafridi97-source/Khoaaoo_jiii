import 'food_model.dart';

class CartItemModel {
  final String id;
  final FoodModel foodItem;
  int quantity;
  final List<String> selectedExtras;
  final String instructions;

  CartItemModel({
    required this.id,
    required this.foodItem,
    this.quantity = 1,
    this.selectedExtras = const [],
    this.instructions = '',
  });

  double get totalPrice {
    double extrasPrice = selectedExtras.length * 50.0;
    return (foodItem.price + extrasPrice) * quantity;
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      foodItem: FoodModel.fromJson(json['foodItem'] ?? {}),
      quantity: json['quantity'] as int? ?? 1,
      selectedExtras: json['selectedExtras'] != null
          ? List<String>.from(json['selectedExtras'])
          : [],
      instructions: json['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodItem': foodItem.toJson(),
      'quantity': quantity,
      'selectedExtras': selectedExtras,
      'instructions': instructions,
    };
  }

  CartItemModel copyWith({
    String? id,
    FoodModel? foodItem,
    int? quantity,
    List<String>? selectedExtras,
    String? instructions,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      instructions: instructions ?? this.instructions,
    );
  }
}
