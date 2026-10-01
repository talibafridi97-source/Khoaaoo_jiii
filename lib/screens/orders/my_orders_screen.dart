import 'package:flutter/material.dart';
import 'order_tracking_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
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
        body: TabBarView(
          children: [
            // Current Orders
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOrderCard(
                  context,
                  orderId: '#QB1024',
                  itemsText: 'Special Chicken Biryani (x1), Cold Drink (x2)',
                  amount: 'Rs. 899',
                  date: 'Today, 02:15 PM',
                  status: 'Preparing',
                  canTrack: true,
                ),
              ],
            ),
            // Previous Orders
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOrderCard(
                  context,
                  orderId: '#QB1019',
                  itemsText: 'Zinger Burger Deluxe (x2), Seekh Kebab Roll (x1)',
                  amount: 'Rs. 1,250',
                  date: 'Yesterday, 08:30 PM',
                  status: 'Delivered',
                  canTrack: false,
                ),
                _buildOrderCard(
                  context,
                  orderId: '#QB1002',
                  itemsText: 'Kabuli Pulao (x1)',
                  amount: 'Rs. 1,200',
                  date: '25 Sep 2026, 01:20 PM',
                  status: 'Delivered',
                  canTrack: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context, {
    required String orderId,
    required String itemsText,
    required String amount,
    required String date,
    required String status,
    required bool canTrack,
  }) {
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
              Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Preparing' ? Colors.orange.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Preparing' ? Colors.deepOrange : Colors.green.shade700,
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
          Text(date, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
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
                          MaterialPageRoute(builder: (context) => OrderTrackingScreen(orderId: orderId)),
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
