import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_model.dart';
import '../models/order_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Fetch food items from Supabase food_items table
  Future<List<FoodModel>> fetchFoodItems() async {
    try {
      final response = await _client.from('food_items').select();
      return (response as List).map((json) {
        return FoodModel(
          id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: json['name'] ?? 'QuickBite Food',
          description: json['description'] ?? '',
          price: (json['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['image'] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
          rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
          deliveryTime: (json['delivery_time'] as num?)?.toInt() ?? 25,
          category: json['category'] ?? 'All',
          isFavorite: json['is_favorite'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      print('Error fetching food items from Supabase: $e');
      return [];
    }
  }

  // Toggle favorite in Supabase
  Future<void> toggleFavorite(String foodId, bool isFavorite) async {
    try {
      await _client.from('food_items').update({'is_favorite': isFavorite}).eq('id', foodId);
    } catch (e) {
      print('Error updating favorite in Supabase: $e');
    }
  }

  // Save order to Supabase orders table with items summary
  Future<bool> placeOrder(OrderModel order, {required String customerName, required String phone, String deliveryNotes = ''}) async {
    try {
      String itemsSummary = order.items.isNotEmpty
          ? order.items.map((i) => '${i.foodItem.name} (x${i.quantity})').join(', ')
          : 'Khoaaoo_jiii Food Order';

      await _client.from('orders').insert({
        'order_id': order.orderId,
        'customer_name': customerName,
        'phone': phone,
        'delivery_address': deliveryAddressWithNotes(order.deliveryAddress, deliveryNotes),
        'total_amount': order.totalAmount,
        'payment_method': order.paymentMethod,
        'status': order.status,
        'timestamp': order.timestamp.toIso8601String(),
        'items_summary': itemsSummary,
      });
      return true;
    } catch (e) {
      print('Error saving order to Supabase: $e');
      return false;
    }
  }

  String deliveryAddressWithNotes(String address, String notes) {
    if (notes.isNotEmpty) {
      return '$address (Note: $notes)';
    }
    return address;
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
          timestamp: json['timestamp'] != null
              ? (DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now())
              : DateTime.now(),
          paymentMethod: json['payment_method'] ?? 'Cash on Delivery',
          itemsSummary: json['items_summary'] ?? 'Delicious Khoaaoo_jiii Meal',
          customerName: json['customer_name'] ?? 'Valued Customer',
          phone: json['phone'] ?? 'N/A',
        );
      }).toList();
    } catch (e) {
      print('Error fetching orders from Supabase: $e');
      return [];
    }
  }

  // Update order status in Supabase orders table
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _client.from('orders').update({'status': newStatus}).eq('order_id', orderId);
      return true;
    } catch (e) {
      print('Error updating order status in Supabase: $e');
      return false;
    }
  }

  // Delete order from Supabase orders table
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _client.from('orders').delete().eq('order_id', orderId);
      return true;
    } catch (e) {
      print('Error deleting order from Supabase: $e');
      return false;
    }
  }
}
