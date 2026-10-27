import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';
import '../../services/supabase_service.dart';
import '../../models/order_model.dart';
import '../home/main_navigation.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartProvider _cartProvider = CartProvider();
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _nameController = TextEditingController(text: 'talibjan');
  final TextEditingController _phoneController = TextEditingController(text: '+92 300 1234567');
  final TextEditingController _addressController = TextEditingController(text: 'House No. 42, Main Bazaar, Kohat City');
  final TextEditingController _voucherController = TextEditingController();
  
  String paymentMethod = 'Cash on Delivery';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cartProvider.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _voucherController.dispose();
    _cartProvider.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  void _applyVoucher() {
    String? error = _cartProvider.applyPromoCode(_voucherController.text);
    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Promo code applied successfully!'), backgroundColor: Colors.green));
    }
  }

  void _handlePlaceOrder() async {
    if (_cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    setState(() => _isLoading = true);

    String orderId = '#QB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    OrderModel order = OrderModel(
      orderId: orderId,
      items: List.from(_cartProvider.items),
      totalAmount: _cartProvider.totalAmount,
      deliveryAddress: _addressController.text.trim(),
      status: 'Preparing',
      timestamp: DateTime.now(),
      paymentMethod: paymentMethod,
    );

    bool success = await _supabaseService.placeOrder(
      order,
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      _cartProvider.clearCart();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 12),
              Text('Order Placed Successfully! 🎉', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('Your order $orderId has been sent to Khoaaoo_jiii Restaurant. Live status syncing active!'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavigation()),
                  (route) => false,
                );
              },
              child: const Text('View My Orders'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Please check connection.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Checkout & Vouchers 🎟️', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Customer Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Delivery Address', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 24),

            // Promo Code Voucher Section
            const Text('Apply Voucher / Promo Code 🎟️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    decoration: InputDecoration(
                      hintText: 'Try KHOAAOO20, FREEDEL, FIRST50',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _applyVoucher,
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (_cartProvider.appliedPromoCode != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Applied: ${_cartProvider.appliedPromoCode}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                  TextButton(
                    onPressed: () => _cartProvider.removePromoCode(),
                    child: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Pay when you receive your order'),
                    value: 'Cash on Delivery',
                    groupValue: paymentMethod,
                    activeColor: Colors.deepOrange,
                    onChanged: (val) => setState(() => paymentMethod = val!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('JazzCash / EasyPaisa', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Mobile wallet online transfer'),
                    value: 'JazzCash / EasyPaisa',
                    groupValue: paymentMethod,
                    activeColor: Colors.deepOrange,
                    onChanged: (val) => setState(() => paymentMethod = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Items Subtotal'),
                      Text('Rs. ${_cartProvider.subtotalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Fee'),
                      Text('Rs. ${_cartProvider.deliveryFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_cartProvider.discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount Voucher', style: TextStyle(color: Colors.green)),
                        Text('- Rs. ${_cartProvider.discountAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Rs. ${_cartProvider.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isLoading ? null : _handlePlaceOrder,
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Place Order • Rs. ${_cartProvider.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
