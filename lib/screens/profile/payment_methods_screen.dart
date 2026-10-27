import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPaymentCard(
            title: 'Cash on Delivery',
            subtitle: 'Pay with cash upon delivery',
            icon: Icons.money,
            isSelected: true,
          ),
          _buildPaymentCard(
            title: 'JazzCash / EasyPaisa Mobile Wallet',
            subtitle: 'Linked via +92 300 1234567',
            icon: Icons.phone_android,
            isSelected: false,
          ),
          _buildPaymentCard(
            title: 'Credit / Debit Card',
            subtitle: 'Add Visa or Mastercard',
            icon: Icons.credit_card,
            isSelected: false,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add New Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment integration coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({required String title, required String subtitle, required IconData icon, required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300, width: isSelected ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6)],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.deepOrange) : null,
      ),
    );
  }
}
