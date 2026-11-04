import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order_model.dart';
import '../../services/supabase_service.dart';
import 'rider_login_screen.dart';

class RiderPortalScreen extends StatefulWidget {
  const RiderPortalScreen({Key? key}) : super(key: key);

  @override
  State<RiderPortalScreen> createState() => _RiderPortalScreenState();
}

class _RiderPortalScreenState extends State<RiderPortalScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _supabaseClient = Supabase.instance.client;
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiderOrders();
    _listenToRealtimeOrders();
  }

  void _listenToRealtimeOrders() {
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
          itemsSummary: json['items_summary'] ?? 'Khoaaoo_jiii Order',
          customerName: json['customer_name'] ?? 'Valued Customer',
          phone: json['phone'] ?? 'N/A',
          assignedRider: json['assigned_rider'] ?? 'Unassigned',
        );
      }).toList();

      setState(() {
        _orders = updatedOrders;
        _isLoading = false;
      });
    });
  }

  Future<void> _loadRiderOrders() async {
    setState(() => _isLoading = true);
    final orders = await _supabaseService.fetchOrders();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    await _supabaseService.updateOrderStatus(orderId, newStatus);
    _loadRiderOrders();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order $orderId status updated to: $newStatus! 🚀'), backgroundColor: Colors.deepOrange),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = _orders.where((o) => o.status != 'Delivered' && o.status != 'Cancelled').toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Delivery Rider Portal (Fleet Dispatch) 🏍️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.deepOrange),
            onPressed: _loadRiderOrders,
            tooltip: 'Refresh Deliveries',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RiderLoginScreen()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : activeOrders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.done_all, size: 70, color: Colors.green),
                      SizedBox(height: 16),
                      Text('No pending deliveries assigned.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeOrders.length,
                  itemBuilder: (context, index) {
                    final order = activeOrders[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                                child: Text(order.status, style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Customer: ${order.customerName.isNotEmpty ? order.customerName : "Valued Customer"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('Phone: ${order.phone}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Delivery Address: ${order.deliveryAddress}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('Cash to Collect: Rs. ${order.totalAmount.toStringAsFixed(0)} (${order.paymentMethod})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 8),
                          Text('Assigned Rider: ${order.assignedRider}', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.blue),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _updateStatus(order.orderId, 'Out for Delivery (On the Way)'),
                                  child: const Text('Start Delivery 🚀', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _updateStatus(order.orderId, 'Delivered'),
                                  child: const Text('Delivered 🏁', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
