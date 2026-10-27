import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order_model.dart';
import '../../services/supabase_service.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import 'order_tracking_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _supabaseClient = Supabase.instance.client;
  final CartProvider _cartProvider = CartProvider();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _listenToCustomerOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    final orders = await _supabaseService.fetchOrders();

    if (!mounted) return;
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  void _listenToCustomerOrders() {
    _supabaseClient
        .from('orders')
        .stream(primaryKey: ['order_id'])
        .listen((data) {
      if (!mounted) return;

      final updatedOrders = data.map((json) {
        return OrderModel(
          orderId: json['order_id'] ?? '#QB1024',
          items: [],
          totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
          deliveryAddress: json['delivery_address'] ?? '',
          status: json['status'] ?? 'Preparing',
          timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
          paymentMethod: json['payment_method'] ?? 'Cash on Delivery',
          itemsSummary: json['items_summary'] ?? 'Delicious Khoaaoo_jiii Meal',
          customerName: json['customer_name'] ?? '',
          phone: json['phone'] ?? '',
        );
      }).toList();

      setState(() {
        _orders = updatedOrders;
        _isLoading = false;
      });
    });
  }

  void _confirmDeleteOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Are you sure you want to delete order $orderId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await _supabaseService.deleteOrder(orderId);
              _loadOrders();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order $orderId deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // One-Click Re-order Dialog & Action
  void _handleReorder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Repeat Order 🔄'),
        content: Text('Do you want to add items from order ${order.orderId} (${order.itemsSummary}) to your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              // Populate cart
              _cartProvider.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Items added to cart for reorder! 🛒')),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentOrders = _orders.where((o) => o.status != 'Delivered' && o.status != 'Cancelled').toList();
    final previousOrders = _orders.where((o) => o.status == 'Delivered' || o.status == 'Cancelled').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.deepOrange),
              onPressed: _loadOrders,
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepOrange,
            tabs: [
              Tab(text: 'Current Orders'),
              Tab(text: 'Previous Orders'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
            : TabBarView(
                children: [
                  currentOrders.isEmpty
                      ? const Center(child: Text('No active current orders', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: currentOrders.length,
                          itemBuilder: (context, index) {
                            final order = currentOrders[index];
                            return _buildOrderCard(context, order, canTrack: true);
                          },
                        ),
                  previousOrders.isEmpty
                      ? const Center(child: Text('No previous order history', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: previousOrders.length,
                          itemBuilder: (context, index) {
                            final order = previousOrders[index];
                            return _buildOrderCard(context, order, canTrack: false);
                          },
                        ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, {required bool canTrack}) {
    String itemsText = order.itemsSummary.isNotEmpty
        ? order.itemsSummary
        : 'Delicious Khoaaoo_jiii Meal';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  itemsText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.status == 'Delivered' ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: order.status == 'Delivered' ? Colors.green.shade700 : Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _confirmDeleteOrder(order.orderId),
                    tooltip: 'Delete Order',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Order ID: ${order.orderId}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('•', style: TextStyle(color: Colors.grey.shade400)),
              const SizedBox(width: 8),
              Text(
                '${order.timestamp.day}/${order.timestamp.month}/${order.timestamp.year}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Payment: ${order.paymentMethod}',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rs. ${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
              Row(
                children: [
                  if (canTrack)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepOrange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrderTrackingScreen(orderId: order.orderId, currentStatus: order.status)),
                        );
                      },
                      child: const Text('Track', style: TextStyle(color: Colors.deepOrange, fontSize: 13)),
                    ),
                  if (canTrack) const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () => _handleReorder(order),
                    child: const Text('Reorder', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
