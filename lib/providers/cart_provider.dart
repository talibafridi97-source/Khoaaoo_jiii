import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';
import '../models/food_model.dart';

class CartProvider extends ChangeNotifier {
  static final CartProvider _instance = CartProvider._internal();
  factory CartProvider() => _instance;
  CartProvider._internal();

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => _items.isEmpty ? 0.0 : 100.0; // Rs. 100

  double get discount => 0.0;

  double get totalAmount => subtotal + (_items.isEmpty ? 0.0 : deliveryFee) - discount;

  void addItem(FoodModel food, {int quantity = 1, List<String> extras = const [], String instructions = ''}) {
    int existingIndex = _items.indexWhere((item) => item.foodItem.id == food.id);
    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          foodItem: food,
          quantity: quantity,
          selectedExtras: extras,
          instructions: instructions,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int delta) {
    int index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
