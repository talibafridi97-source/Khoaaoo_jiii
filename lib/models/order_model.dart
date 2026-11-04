import 'cart_model.dart';

class OrderModel {
  final String orderId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String deliveryAddress;
  final String status; // 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled'
  final DateTime timestamp;
  final String paymentMethod;
  final String itemsSummary;
  final String customerName;
  final String phone;
  final String assignedRider;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    required this.timestamp,
    this.paymentMethod = 'Cash on Delivery',
    this.itemsSummary = '',
    this.customerName = '',
    this.phone = '',
    this.assignedRider = 'Unassigned',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['_id'] ?? json['orderId'] ?? json['order_id'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => CartItemModel.fromJson(item))
              .toList()
          : [],
      totalAmount: (json['totalAmount'] ?? json['total_amount'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: json['deliveryAddress'] ?? json['delivery_address'] ?? '',
      status: json['status'] ?? 'Pending',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'Cash on Delivery',
      itemsSummary: json['items_summary'] ?? '',
      customerName: json['customer_name'] ?? '',
      phone: json['phone'] ?? '',
      assignedRider: json['assigned_rider'] ?? 'Unassigned',
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
      'items_summary': itemsSummary,
      'customer_name': customerName,
      'phone': phone,
      'assigned_rider': assignedRider,
    };
  }
}
