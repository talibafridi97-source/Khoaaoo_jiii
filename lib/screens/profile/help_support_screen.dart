import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepOrange.shade400, Colors.orange.shade600]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need immediate assistance?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Our support team in Kohat is available 24/7 to help you with your food delivery orders.', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Contact Us & Live Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.deepOrange),
                  title: const Text('Helpline Number', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('+92 300 1234567'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling helpline...')));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text('WhatsApp Live Support 💬', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Connect instantly with restaurant manager'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening WhatsApp chat support (+92 300 1234567)...'), backgroundColor: Colors.green));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.deepOrange),
                  title: const Text('Email Support', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('support@khoaaoojiii.pk'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening email client...')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
