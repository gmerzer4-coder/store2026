import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:store2026/src/presentation/pages/home_page.dart';
import 'package:store2026/src/presentation/providers/product_provider.dart';
import 'package:store2026/src/data/in_memory_product_repository.dart';

void main() {
  testWidgets('HomePage shows FloatingActionButton (Add)', (WidgetTester tester) async {
    // Provide ProductProvider with InMemory repo to avoid Firebase
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(repository: InMemoryProductRepository()),
          child: const HomePage(),
        ),
      ),
    );

    // let provider load
    await tester.pumpAndSettle();

    // Expect a FloatingActionButton exists
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Also ensure tooltip/icon exists
    expect(find.byTooltip('إضافة منتج'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
