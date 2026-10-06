import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_model.dart';
import '../models/order_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Fetch food items from Supabase food_items table
  Future<List<FoodModel>> fetchFoodItems() async {
    try {
      final response = await _client.from('food_items').select();
      return (response as List).map((json) => FoodModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching food items from Supabase: $e');
      return [];
    }
  }

  // Save order to Supabase orders table
  Future<bool> placeOrder(OrderModel order) async {
    try {
      await _client.from('orders').insert({
        'order_id': order.orderId,
        'customer_name': 'Talib Nawaz',
        'phone': '+92 300 1234567',
        'delivery_address': order.deliveryAddress,
        'total_amount': order.totalAmount,
        'payment_method': order.paymentMethod,
        'status': order.status,
        'timestamp': order.timestamp.toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving order to Supabase: $e');
      return false;
    }
  }

  // Fetch orders from Supabase orders table
  Future<List<OrderModel>> fetchOrders() async {
    try {
      final response = await _client.from('orders').select();
      return (response as List).map((json) {
        return OrderModel(
          orderId: json['order_id'] ?? '#QB1024',
          items: [],
          totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
          deliveryAddress: json['delivery_address'] ?? '',
          status: json['status'] ?? 'Preparing',
          timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
          paymentMethod: json['payment_method'] ?? 'Cash on Delivery',
        );
      }).toList();
    } catch (e) {
      print('Error fetching orders from Supabase: $e');
      return [];
    }
  }
}
