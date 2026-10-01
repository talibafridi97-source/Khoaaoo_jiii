import 'package:flutter/material.dart';
import '../../data/food_data.dart';
import '../../models/food_model.dart';
import '../../models/category_model.dart';
import '../../widgets/category_card.dart';
import '../../widgets/offer_card.dart';
import '../../widgets/food_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';
  List<FoodModel> foodList = FoodData.foodItems;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Location & Profile Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
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
                          icon: const Icon(Icons.notifications_none, color: Colors.black87),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No new notifications')),
                            );
                          },
                        ),
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
                      imagePath: 'assets/images/burger.jpg',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Zinger Deal selected!')),
                        );
                      },
                    ),
                    OfferCard(
                      title: 'Special Biryani Special',
                      subtitle: 'Authentic chicken biryani combo',
                      discount: 'Rs. 100 OFF',
                      imagePath: 'assets/images/chicken_biryani.jpg',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Biryani Deal selected!')),
                        );
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
                mainAxisAlignment: MainAxisAlignment.between,
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tapped on ${food.name}')),
                            );
                          },
                          onAddPressed: () {
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
