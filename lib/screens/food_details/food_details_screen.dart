import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../providers/cart_provider.dart';

class FoodDetailsScreen extends StatefulWidget {
  final FoodModel food;
  const FoodDetailsScreen({Key? key, required this.food}) : super(key: key);

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  String selectedSize = 'Regular';
  final List<String> selectedAddons = [];
  final TextEditingController _notesController = TextEditingController();
  final CartProvider _cartProvider = CartProvider();

  double get calculatedPrice {
    double base = widget.food.price;
    if (selectedSize == 'Medium') base += 150;
    if (selectedSize == 'Large') base += 300;
    for (var addon in selectedAddons) {
      if (addon == 'Extra Cheese') base += 60;
      if (addon == 'Extra Sauce') base += 30;
      if (addon == 'Extra Patty') base += 180;
    }
    return base;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.deepOrange,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.food.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.food.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Rs. ${calculatedPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${widget.food.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Text('${widget.food.deliveryTime} mins', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    widget.food.description,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Portion / Size Selection
                  const Text('Select Portion / Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: ['Regular', 'Medium', 'Large'].map((size) {
                      bool isSelected = selectedSize == size;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedSize = size),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.deepOrange : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300),
                            ),
                            child: Center(
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Add-ons & Toppings
                  const Text('Add-ons & Toppings 🧀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...['Extra Cheese (+Rs. 60)', 'Extra Sauce (+Rs. 30)', 'Extra Patty (+Rs. 180)'].map((addonName) {
                    String cleanName = addonName.split(' (').first;
                    bool isChecked = selectedAddons.contains(cleanName);
                    return CheckboxListTile(
                      title: Text(addonName),
                      value: isChecked,
                      activeColor: Colors.deepOrange,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedAddons.add(cleanName);
                          } else {
                            selectedAddons.remove(cleanName);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),

                  // Special Cooking Instructions
                  const Text('Special Cooking Instructions 📝', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Kam mirch rakhna, Pyaz na daalna...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              _cartProvider.addItem(
                widget.food,
                size: selectedSize,
                addons: List.from(selectedAddons),
                notes: _notesController.text.trim(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added ${widget.food.name} ($selectedSize) to cart!')),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Add to Cart • Rs. ${calculatedPrice.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
