import 'food_model.dart';

class CartItemModel {
  final FoodModel foodItem;
  int quantity;
  String selectedSize; // 'Regular', 'Medium', 'Large'
  List<String> selectedAddons; // ['Extra Cheese', 'Extra Sauce', 'Extra Patty']
  String cookingInstructions;

  CartItemModel({
    required this.foodItem,
    this.quantity = 1,
    this.selectedSize = 'Regular',
    this.selectedAddons = const [],
    this.cookingInstructions = '',
  });

  double get adjustedPrice {
    double base = foodItem.price;
    if (selectedSize == 'Medium') base += 150;
    if (selectedSize == 'Large') base += 300;
    for (var addon in selectedAddons) {
      if (addon == 'Extra Cheese') base += 60;
      if (addon == 'Extra Sauce') base += 30;
      if (addon == 'Extra Patty') base += 180;
    }
    return base;
  }

  double get totalPrice => adjustedPrice * quantity;

  Map<String, dynamic> toJson() => {
    'foodItem': foodItem.toJson(),
    'quantity': quantity,
    'selectedSize': selectedSize,
    'selectedAddons': selectedAddons,
    'cookingInstructions': cookingInstructions,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      foodItem: FoodModel.fromJson(json['foodItem']),
      quantity: json['quantity'] ?? 1,
      selectedSize: json['selectedSize'] ?? 'Regular',
      selectedAddons: List<String>.from(json['selectedAddons'] ?? []),
      cookingInstructions: json['cookingInstructions'] ?? '',
    );
  }
}
