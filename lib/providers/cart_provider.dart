import 'package:flutter/foundation.dart';
import '../models/food_model.dart';
import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  static final CartProvider _instance = CartProvider._internal();
  factory CartProvider() => _instance;
  CartProvider._internal();

  final List<CartItemModel> _items = [];
  String? _appliedPromoCode;
  double _discountAmount = 0.0;

  List<CartItemModel> get items => _items;
  String? get appliedPromoCode => _appliedPromoCode;
  double get discountAmount => _discountAmount;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => _items.isEmpty ? 0.0 : 100.0;

  double get totalAmount {
    double total = subtotalAmount + deliveryFee - _discountAmount;
    return total < 0 ? 0 : total;
  }

  void addItem(FoodModel food, {String size = 'Regular', List<String> addons = const [], String notes = ''}) {
    int index = _items.indexWhere((i) => i.foodItem.id == food.id && i.selectedSize == size);
    if (index != -1) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItemModel(
        foodItem: food,
        quantity: 1,
        selectedSize: size,
        selectedAddons: addons,
        cookingInstructions: notes,
      ));
    }
    notifyListeners();
  }

  void removeItem(CartItemModel item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateQuantity(CartItemModel item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) {
      _items.remove(item);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedPromoCode = null;
    _discountAmount = 0.0;
    notifyListeners();
  }

  // Promo Code Voucher Logic
  String? applyPromoCode(String code) {
    String cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'KHOAAOO20') {
      _appliedPromoCode = 'KHOAAOO20 (20% OFF)';
      _discountAmount = subtotalAmount * 0.20;
      notifyListeners();
      return null;
    } else if (cleanCode == 'FREEDEL') {
      _appliedPromoCode = 'FREEDEL (Free Delivery)';
      _discountAmount = deliveryFee;
      notifyListeners();
      return null;
    } else if (cleanCode == 'FIRST50') {
      _appliedPromoCode = 'FIRST50 (Rs. 50 OFF)';
      _discountAmount = 50.0;
      notifyListeners();
      return null;
    } else {
      return 'Invalid promo code! Try KHOAAOO20, FREEDEL, or FIRST50';
    }
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _discountAmount = 0.0;
    notifyListeners();
  }

  // Re-order feature
  void reorderItems(List<CartItemModel> previousItems) {
    _items.clear();
    _items.addAll(previousItems);
    notifyListeners();
  }
}
