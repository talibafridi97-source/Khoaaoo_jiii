import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/supabase_service.dart';
import 'order_tracking_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
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
                  // Current Orders
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
                  // Previous Orders
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
    String itemsText = order.items.isNotEmpty
        ? order.items.map((i) => '${i.foodItem.name} (x${i.quantity})').join(', ')
        : 'Delicious QuickBite Meal';

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
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            ],
          ),
          const SizedBox(height: 8),
          Text(itemsText, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '${order.timestamp.day}/${order.timestamp.month}/${order.timestamp.year} - ${order.paymentMethod}',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
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
                          MaterialPageRoute(builder: (context) => OrderTrackingScreen(orderId: order.orderId)),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Items added to cart for reorder!')),
                      );
                    },
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
