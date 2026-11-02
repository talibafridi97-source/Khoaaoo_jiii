import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';
import '../../services/supabase_service.dart';
import '../../services/loyalty_service.dart';
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
  final LoyaltyService _loyaltyService = LoyaltyService();
  final TextEditingController _nameController = TextEditingController(text: 'talibjan');
  final TextEditingController _phoneController = TextEditingController(text: '+92 300 1234567');
  final TextEditingController _addressController = TextEditingController(text: 'House No. 42, Main Bazaar, Kohat City');
  final TextEditingController _voucherController = TextEditingController();
  
  String paymentMethod = 'Cash on Delivery';
  String deliveryTimeSlot = 'Deliver Now (25-35 mins)';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cartProvider.addListener(_onCartChanged);
    _loyaltyService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _voucherController.dispose();
    _cartProvider.removeListener(_onCartChanged);
    _loyaltyService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  double get totalWithLoyalty {
    double total = _cartProvider.totalAmount - _loyaltyService.redeemableDiscount;
    return total < 0 ? 0 : total;
  }

  void _useCurrentGpsLocation() {
    setState(() {
      _addressController.text = 'GPS Verified: Kohat University Road, Sector 3, Kohat (Lat: 33.58, Lng: 71.44)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📍 Current GPS Location fetched successfully!'), backgroundColor: Colors.green),
    );
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
      totalAmount: totalWithLoyalty,
      deliveryAddress: '${_addressController.text.trim()} [Time: $deliveryTimeSlot]',
      status: 'Preparing',
      timestamp: DateTime.now(),
      paymentMethod: paymentMethod,
    );

    bool success = await _supabaseService.placeOrder(
      order,
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (success) {
      // Award loyalty coins (10% of order total) and deduct redeemed coins
      int earnedCoins = (_cartProvider.subtotalAmount * 0.1).toInt();
      _loyaltyService.addPoints(earnedCoins);
      _loyaltyService.deductPointsAfterOrder();
    }

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
          content: Text('Your order $orderId has been placed! You earned loyalty coins on this order.'),
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
        title: const Text('Checkout & Rewards Wallet 🪙', style: TextStyle(fontWeight: FontWeight.bold)),
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
              decoration: InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.deepOrange),
                  tooltip: 'Use Current GPS Location',
                  onPressed: _useCurrentGpsLocation,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _useCurrentGpsLocation,
                icon: const Icon(Icons.gps_fixed, size: 16, color: Colors.deepOrange),
                label: const Text('📍 Use Current GPS Location', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 16),

            // Loyalty Points Wallet Redemption Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade800]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.monetization_on, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text('Khoaaoo Coins Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Text('${_loyaltyService.points} Coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Available discount value: Rs. ${_loyaltyService.points / 10.0}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const Divider(color: Colors.white30, height: 20),
                  CheckboxListTile(
                    title: const Text('Redeem loyalty coins for discount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    value: _loyaltyService.isRedeeming,
                    activeColor: Colors.white,
                    checkColor: Colors.deepOrange,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      _loyaltyService.toggleRedeem(val ?? false);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Schedule Delivery Time
            const Text('Schedule Delivery Time ⏰', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Deliver Now (25-35 mins)', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Standard fresh & hot delivery'),
                    value: 'Deliver Now (25-35 mins)',
                    groupValue: deliveryTimeSlot,
                    activeColor: Colors.deepOrange,
                    onChanged: (val) => setState(() => deliveryTimeSlot = val!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Schedule for Later (Tonight 8:00 PM)', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Pre-order in advance'),
                    value: 'Schedule for Tonight 8:00 PM',
                    groupValue: deliveryTimeSlot,
                    activeColor: Colors.deepOrange,
                    onChanged: (val) => setState(() => deliveryTimeSlot = val!),
                  ),
                ],
              ),
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
                  if (_loyaltyService.isRedeeming) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Coins Discount', style: TextStyle(color: Colors.amber)),
                        Text('- Rs. ${_loyaltyService.redeemableDiscount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Rs. ${totalWithLoyalty.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
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
                    : Text('Place Order • Rs. ${totalWithLoyalty.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
