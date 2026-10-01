import 'cart_model.dart';

class OrderModel {
  final String orderId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String deliveryAddress;
  final String status; // 'Pending', 'Preparing', 'On the Way', 'Delivered', 'Cancelled'
  final DateTime timestamp;
  final String paymentMethod; // 'Cash on Delivery', 'Credit Card'

  OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    required this.timestamp,
    this.paymentMethod = 'Cash on Delivery',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['_id'] ?? json['orderId'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => CartItemModel.fromJson(item))
              .toList()
          : [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: json['deliveryAddress'] ?? '',
      status: json['status'] ?? 'Pending',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? 'Cash on Delivery',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'paymentMethod': paymentMethod,
    };
  }
}
