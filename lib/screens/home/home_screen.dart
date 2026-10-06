import 'package:flutter/material.dart';
import '../../data/food_data.dart';
import '../../models/food_model.dart';
import '../../widgets/category_card.dart';
import '../../widgets/offer_card.dart';
import '../../widgets/food_card.dart';
import '../food_details/food_details_screen.dart';
import '../cart/cart_screen.dart';
import '../../providers/cart_provider.dart';
import '../../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';
  List<FoodModel> foodList = [];
  bool isLoading = true;
  final CartProvider _cartProvider = CartProvider();
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _cartProvider.addListener(_onCartChanged);
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    setState(() {
      isLoading = true;
    });

    final items = await _supabaseService.fetchFoodItems();
    
    if (!mounted) return;
    setState(() {
      // If Supabase has items, use them; otherwise fallback to local mock data so UI is never empty
      foodList = items.isNotEmpty ? items : FoodData.foodItems;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _cartProvider.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<FoodModel> filteredFoodList = foodList.where((food) {
      bool matchesCategory = selectedCategory == 'All' || food.category == selectedCategory;
      bool matchesSearch = food.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          food.description.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Location & Profile Icons & Cart Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.deepOrange, size: 28),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Deliver to',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                Row(
                                  children: const [
                                    Text(
                                      'Kohat City',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_down, size: 18),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Cart Icon with Badge
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const CartScreen()),
                                      );
                                    },
                                  ),
                                ),
                                if (_cartProvider.itemCount > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.deepOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${_cartProvider.itemCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.person, color: Colors.deepOrange),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Profile tapped')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for food...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                          suffixIcon: const Icon(Icons.tune, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Special Offers Section
                    const Text(
                      'Special Offers 🔥',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 150,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          OfferCard(
                            title: 'Zinger Deal Feast',
                            subtitle: 'Crispy burger with fries & drink',
                            discount: '20% OFF',
                            imagePath: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
                            onTap: () {
                              if (foodList.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodDetailsScreen(food: foodList.first),
                                  ),
                                );
                              }
                            },
                          ),
                          OfferCard(
                            title: 'Special Biryani Feast',
                            subtitle: 'Authentic chicken biryani combo',
                            discount: 'Rs. 100 OFF',
                            imagePath: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500',
                            onTap: () {
                              if (foodList.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodDetailsScreen(food: foodList.first),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Food Categories Section
                    const Text(
                      'Food Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: FoodData.categories.length,
                        itemBuilder: (context, index) {
                          final category = FoodData.categories[index];
                          bool isSelected = selectedCategory == category.name;
                          return CategoryCard(
                            category: category,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                selectedCategory = category.name;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Popular Near You Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Popular Near You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'See All',
                            style: TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Food Items Grid
                    filteredFoodList.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'No food items found',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: filteredFoodList.length,
                            itemBuilder: (context, index) {
                              final food = filteredFoodList[index];
                              return FoodCard(
                                food: food,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FoodDetailsScreen(food: food),
                                    ),
                                  );
                                },
                                onAddPressed: () {
                                  _cartProvider.addItem(food);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Added ${food.name} to cart!')),
                                  );
                                },
                                onFavoritePressed: () {
                                  setState(() {
                                    int originalIndex = foodList.indexWhere((item) => item.id == food.id);
                                    if (originalIndex != -1) {
                                      foodList[originalIndex] = foodList[originalIndex].copyWith(
                                        isFavorite: !foodList[originalIndex].isFavorite,
                                      );
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}
