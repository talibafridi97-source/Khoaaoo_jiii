import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({Key? key}) : super(key: key);

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(text: '25');
  
  String _selectedCategory = 'Biryani & Pulao';
  final List<String> _categories = ['Biryani & Pulao', 'Fast Food', 'BBQ & Karahi', 'Beverages'];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _saveFoodItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Supabase.instance.client.from('food_items').insert({
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'image_url': _imageController.text.trim().isNotEmpty
              ? _imageController.text.trim()
              : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
          'rating': 4.8,
          'delivery_time': int.parse(_timeController.text.trim()),
          'category': _selectedCategory,
          'is_favorite': false,
        });

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food item added successfully to Supabase!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding food item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Add New Food Item', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Food Item Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Food Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    validator: (v) => v == null || v.isEmpty ? 'Enter food name' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Price (PKR)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    validator: (v) => v == null || v.isEmpty || double.tryParse(v) == null ? 'Enter valid price' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _timeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Delivery Time (Minutes)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    validator: (v) => v == null || v.isEmpty ? 'Enter delivery time' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(labelText: 'Image URL (Unsplash or Image Link)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), hintText: 'https://images.unsplash.com/...'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _saveFoodItem,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save Food Item to Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
