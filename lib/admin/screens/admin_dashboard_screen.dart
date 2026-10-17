import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order_model.dart';
import '../../models/food_model.dart';
import '../../services/supabase_service.dart';
import 'add_food_screen.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseService _supabaseService = SupabaseService();
  final _supabaseClient = Supabase.instance.client;
  
  List<OrderModel> _orders = [];
  List<FoodModel> _foodItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdminData();
    _listenToRealtimeOrders();
  }

  // Supabase Realtime Stream: Listen to new incoming orders instantly like WhatsApp!
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
          itemsSummary: json['items_summary'] ?? 'Delicious QuickBite Meal',
        );
      }).toList();

      // Check if a new order arrived
      if (updatedOrders.length > _orders.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔔 NEW ORDER RECEIVED! Check customer orders tab.'),
            backgroundColor: Colors.deepOrange,
            duration: Duration(seconds: 5),
          ),
        );
      }

      setState(() {
        _orders = updatedOrders;
      });
    });
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    final orders = await _supabaseService.fetchOrders();
    final food = await _supabaseService.fetchFoodItems();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _foodItems = food;
      _isLoading = false;
    });
  }

  Future<void> _deleteFoodItem(String id) async {
    try {
      await _supabaseClient.from('food_items').delete().eq('id', id);
      _loadAdminData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food item deleted successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
    }
  }

  void _showOrderDetailsDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Details (${order.orderId})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(order.status, style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              const Text('Ordered Items:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(order.itemsSummary.isNotEmpty ? order.itemsSummary : 'QuickBite Food Order', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Delivery Address:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(order.deliveryAddress, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 16),
              const Text('Payment & Total:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              Text('Rs. ${order.totalAmount.toStringAsFixed(0)} (${order.paymentMethod})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 16),
              const Text('Order Time:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(order.timestamp.toString(), style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 24),
              const Text('Update Order Status / Inform Customer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    onPressed: () async {
                      await _supabaseService.updateOrderStatus(order.orderId, 'Preparing');
                      Navigator.pop(context);
                      _loadAdminData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated to Preparing')));
                    },
                    child: const Text('Preparing'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    onPressed: () async {
                      await _supabaseService.updateOrderStatus(order.orderId, 'Out for Delivery (10-15 mins)');
                      Navigator.pop(context);
                      _loadAdminData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated: Out for Delivery')));
                    },
                    child: const Text('Out for Delivery'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () async {
                      await _supabaseService.updateOrderStatus(order.orderId, 'Delivered');
                      Navigator.pop(context);
                      _loadAdminData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated to Delivered')));
                    },
                    child: const Text('Delivered'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('QuickBite Restaurant Admin Dashboard (Live)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.deepOrange),
            onPressed: _loadAdminData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Customer Orders'),
            Tab(icon: Icon(Icons.fastfood), text: 'Menu Management'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Customer Orders
                _orders.isEmpty
                    ? const Center(child: Text('No orders received yet.', style: TextStyle(color: Colors.grey, fontSize: 16)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return InkWell(
                            onTap: () => _showOrderDetailsDialog(order),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Order: ${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                                          child: Text(order.status, style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Items: ${order.itemsSummary.isNotEmpty ? order.itemsSummary : "QuickBite Order"}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    Text('Delivery Address: ${order.deliveryAddress}', style: TextStyle(color: Colors.grey.shade700)),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total Bill: Rs. ${order.totalAmount.toStringAsFixed(0)} (${order.paymentMethod})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const Text('Tap to view details & update status ➔', style: TextStyle(color: Colors.deepOrange, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                // Tab 2: Menu Management
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Restaurant Menu Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Food Item'),
                            onPressed: () async {
                              final added = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddFoodScreen()),
                              );
                              if (added == true) _loadAdminData();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _foodItems.isEmpty
                            ? const Center(child: Text('No food items found in Supabase.', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                itemCount: _foodItems.length,
                                itemBuilder: (context, index) {
                                  final food = _foodItems[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(food.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.fastfood)),
                                      ),
                                      title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text('${food.category} • Rs. ${food.price.toStringAsFixed(0)} • ${food.deliveryTime} mins'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteFoodItem(food.id),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
