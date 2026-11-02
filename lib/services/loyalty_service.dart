import 'package:flutter/material.dart';

class LoyaltyService extends ChangeNotifier {
  static final LoyaltyService _instance = LoyaltyService._internal();
  factory LoyaltyService() => _instance;
  LoyaltyService._internal();

  int _points = 250; // Initial welcome reward points
  bool _isRedeeming = false;

  int get points => _points;
  bool get isRedeeming => _isRedeeming;

  // 10 points = Rs. 1 discount
  double get redeemableDiscount => _isRedeeming ? (_points / 10.0) : 0.0;

  void toggleRedeem(bool redeem) {
    _isRedeeming = redeem;
    notifyListeners();
  }

  void addPoints(int earned) {
    _points += earned;
    notifyListeners();
  }

  void deductPointsAfterOrder() {
    if (_isRedeeming) {
      _points = 0; // Use all points
      _isRedeeming = false;
      notifyListeners();
    }
  }
}
