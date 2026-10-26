import 'package:flutter/material.dart';
import '../../data/food_data.dart';
import '../../models/food_model.dart';
import '../../widgets/food_card.dart';
import '../food_details/food_details_screen.dart';
import '../../providers/cart_provider.dart';
import '../../services/supabase_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  String sortBy = 'Default'; // Default, Price: Low to High, Price: High to Low, Highest Rated
  final TextEditingController _searchController = TextEditingController();
  final CartProvider _cartProvider = CartProvider();
  final SupabaseService _supabaseService = SupabaseService();
  List<FoodModel> foodList = FoodData.foodItems;

  @override
  void initState() {
    super.initState();
    _loadFood();
  }

  Future<void> _loadFood() async {
    final items = await _supabaseService.fetchFoodItems();
    if (!mounted) return;
    setState(() {
      if (items.isNotEmpty) foodList = items;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<FoodModel> searchResults = foodList.where((food) {
      return food.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          food.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          food.category.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // Sorting logic
    if (sortBy == 'Price: Low to High') {
      searchResults.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'Price: High to Low') {
      searchResults.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'Highest Rated') {
      searchResults.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Search & Filter Food 🔍', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search Burger, Biryani, Drink...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Sorting Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Default', 'Price: Low to High', 'Price: High to Low', 'Highest Rated'].map((filter) {
                  bool isSelected = sortBy == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: Colors.deepOrange,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                      onSelected: (selected) {
                        setState(() {
                          sortBy = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Search Results or Empty State
            Expanded(
              child: searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'No food items found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try searching for Burger, Biryani, Pulao or Drinks',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final food = searchResults[index];
                        return FoodCard(
                          food: food,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FoodDetailsScreen(food: food)),
                            ).then((_) => _loadFood());
                          },
                          onAddPressed: () {
                            _cartProvider.addItem(food);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added ${food.name} to cart!')),
                            );
                          },
                          onFavoritePressed: () async {
                            bool newFav = !food.isFavorite;
                            await _supabaseService.toggleFavorite(food.id, newFav);
                            setState(() {
                              int originalIndex = foodList.indexWhere((item) => item.id == food.id);
                              if (originalIndex != -1) {
                                foodList[originalIndex] = foodList[originalIndex].copyWith(
                                  isFavorite: newFav,
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
