import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khoaaoo_jiiii/main.dart';

void main() {
  testWidgets('QuickBite App test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuickBiteApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
