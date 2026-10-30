import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  bool _isUrdu = false;
  bool get isUrdu => _isUrdu;

  void toggleLanguage(bool isUrduSelected) {
    _isUrdu = isUrduSelected;
    notifyListeners();
  }

  String translate(String englishText) {
    if (!_isUrdu) return englishText;

    final Map<String, String> urduMap = {
      'Deliver to': 'ڈیلیوری مقام',
      'Kohat City': 'کوہاٹ سٹی',
      'Search for food...': 'مزیدار کھانے تلاش کریں...',
      'Special Offers 🔥': 'خصوصی آفرز 🔥',
      'Food Categories': 'کھانے کی کیٹیگریز',
      'Popular Near You': 'آپ کے قریب مقبول',
      'Refresh Menu': 'مینو ریفرش کریں',
      'My Cart': 'میری کارٹ',
      'Your cart is empty': 'آپ کی کارٹ خالی ہے',
      'Add delicious food items to get started!': 'مزیدار کھانے شامل کریں!',
      'Explore Menu': 'مینو دیکھیں',
      'Proceed to Checkout': 'چیک آؤٹ کریں',
      'My Orders': 'میرے آرڈرز',
      'CurrentOrders': 'جاری آرڈرز',
      'PreviousOrders': 'گزشتہ آرڈرز',
      'My Favorites ❤️': 'پسندیدہ اشیاء ❤️',
      'My Profile': 'میری پروفائل',
      'Dark Mode': 'ڈارک موڈ',
      'Logout': 'لاگ آؤٹ',
      'Help & Support': 'مدد اور سپورٹ',
      'Settings & Notifications': 'سیٹنگز اور نوٹیفیکیشنز',
      'Payment Methods': 'ادائیگی کے طریقے',
      'Language (English / اردو)': 'زبان (English / اردو)',
    };

    return urduMap[englishText] ?? englishText;
  }
}
