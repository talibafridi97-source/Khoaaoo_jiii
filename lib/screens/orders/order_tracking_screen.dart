import 'package:flutter/material.dart';
import '../chat/live_chat_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final String currentStatus;

  const OrderTrackingScreen({Key? key, this.orderId = '#QB1024', this.currentStatus = 'Preparing'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPreparing = true;
    bool isConfirmed = true;
    bool isOutForDelivery = currentStatus.toLowerCase().contains('out for delivery') || currentStatus.toLowerCase().contains('delivered');
    bool isDelivered = currentStatus.toLowerCase().contains('delivered');

    final steps = [
      {'title': 'Order Placed', 'subtitle': 'We have received your order.', 'isCompleted': true},
      {'title': 'Order Confirmed', 'subtitle': 'Restaurant has accepted your order.', 'isCompleted': isConfirmed},
      {'title': 'Preparing Food', 'subtitle': 'Your delicious food is being freshly prepared.', 'isCompleted': isPreparing},
      {'title': 'Out for Delivery', 'subtitle': 'Rider is on the way to your delivery address.', 'isCompleted': isOutForDelivery},
      {'title': 'Delivered', 'subtitle': 'Enjoy your meal!', 'isCompleted': isDelivered},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Track Order $orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.deepOrange),
            tooltip: 'Live Chat with Manager',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LiveChatScreen(orderId: orderId)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feature 2: Rider Live Map Radar / Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.deepOrange.shade500, Colors.orange.shade600]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.delivery_dining, size: 36, color: Colors.deepOrange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Assigned Delivery Rider', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 2),
                        const Text('Rider Ali (Honda 125 • KHT-786)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            const Text('4.9 (120+ deliveries)', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.phone, color: Colors.deepOrange, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling Rider Ali (+92 300 9876543)...')));
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepOrange)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDelivered ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          currentStatus,
                          style: TextStyle(
                            color: isDelivered ? Colors.green.shade700 : Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text('Estimated Delivery: 25-35 mins', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text('Delivery Address: Kohat City', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Live Status Sync', style: TextStyle(color: Colors.grey)),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text('Live Chat with Manager'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LiveChatScreen(orderId: orderId)),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Timeline (Live Updates)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Vertical Timeline
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final bool isCompleted = step['isCompleted'] as bool;
                final bool isLast = index == steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? Colors.deepOrange : Colors.grey.shade300,
                          ),
                          child: Center(
                            child: Icon(
                              isCompleted ? Icons.check : Icons.circle,
                              size: isCompleted ? 16 : 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 45,
                            color: isCompleted ? Colors.deepOrange : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isCompleted ? Colors.black87 : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step['subtitle'] as String,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
