import 'dart:async';
import 'package:uuid/uuid.dart';
import '../domain/entities/product.dart';
import '../domain/repositories/product_repository.dart';

class InMemoryProductRepository implements ProductRepository {
  final List<Product> _items = [];
  final _uuid = const Uuid();

  InMemoryProductRepository() {
    // Prepare a map of specific seeded products with detailed descriptions/prices
    final Map<String, Map<String, dynamic>> detailed = {
      '30': {'name': 'شنطة سوداء مميزة', 'category': 'شنط', 'description': 'شنطة سوداء مميزة مع حركة يمين/يسار أنيقة.', 'price': 249.0},
      '40': {'name': 'حقيبة صفراء جذابة', 'category': 'شنط', 'description': 'حقيبة نسائية صفراء جذابة.', 'price': 199.0},
      '20': {'name': 'شنطة كلاسيكية بنية', 'category': 'شنط', 'description': 'شنطة بنية كلاسيكية مصنوعة من خامات فاخرة.', 'price': 179.0},
      '24': {'name': 'شنطة زهري أنيق', 'category': 'شنط', 'description': 'شنطة بلون زهري أنيق.', 'price': 159.0},
      '80': {'name': 'شنطة بنية فخمة', 'category': 'شنط', 'description': 'تصميم فخم بلمسات جلدية.', 'price': 299.0},
      '6': {'name': 'شنطة زهري مع أبيض', 'category': 'شنط', 'description': 'تصميم زهري وقطع بيضاء.', 'price': 149.0},

      '70': {'name': 'بوتي أسود بنفسجي', 'category': 'أحذية', 'description': 'بوتي أسود مع تدرجات بنفسجية.', 'price': 129.0},
      '60': {'name': 'أحذية ألوان فاتحة', 'category': 'أحذية', 'description': 'أحذية بألوان فاتحة رائعة.', 'price': 119.0},
      '10': {'name': 'بوتي رجالي أبيض وأسود', 'category': 'أحذية', 'description': 'بوتي رجالي أبيض وأسود.', 'price': 139.0},
      '50': {'name': 'بوتي أسود وسماوي', 'category': 'أحذية', 'description': 'حذاء أسود مع خط سماوي.', 'price': 129.0},
      '23': {'name': 'بوتي رجالي أسود', 'category': 'أحذية', 'description': 'حذاء رجالي كلاسيكي أسود.', 'price': 149.0},
      '22': {'name': 'بوتي بني وأبيض', 'category': 'أحذية', 'description': 'حذاء بني مع لمسات بيضاء.', 'price': 139.0},
      '21': {'name': 'بوتي بخيوط بيضاء', 'category': 'أحذية', 'description': 'حذاء أسود مع خيوط بيضاء.', 'price': 129.0},
      '27': {'name': 'بوتي بني فردة', 'category': 'أحذية', 'description': 'قطعة بنية فردة.', 'price': 89.0},
      '13': {'name': 'بوتي سماوي فردة', 'category': 'أحذية', 'description': 'حذاء سماوي فردة.', 'price': 79.0},
      '29': {'name': 'بوتي أبيض رياضي', 'category': 'أحذية', 'description': 'حذاء رياضي أبيض مريح.', 'price': 119.0},
      '5': {'name': 'جزمة بنية', 'category': 'أحذية', 'description': 'جزمة بنية أنيقة.', 'price': 159.0},
    };

    // add generic products for 1..80, but override with detailed where provided
    for (var i = 1; i <= 80; i++) {
      final key = i.toString();
      if (detailed.containsKey(key)) {
        final d = detailed[key]!;
        _items.add(Product(
          id: _uuid.v4(),
          name: d['name'] as String,
          imageName: key,
          category: d['category'] as String,
          description: d['description'] as String,
          price: d['price'] as double,
        ));
      } else {
        _items.add(Product(
          id: _uuid.v4(),
          name: 'منتج رقم $key',
          imageName: key,
          category: i % 3 == 0 ? 'شنط' : (i % 2 == 0 ? 'أحذية' : 'رجالي'),
          description: 'وصف افتراضي للمنتج $key',
          price: 99.0 + (i % 20),
        ));
      }
    }
  }

  @override
  Future<void> add(Product product) async {
    final p = Product(
      id: _uuid.v4(),
      name: product.name,
      imageName: product.imageName,
      category: product.category,
      description: product.description,
      price: product.price,
    );
    _items.add(p);
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Product>> getAll() async {
    return List.unmodifiable(_items);
  }

  @override
  Future<void> update(Product product) async {
    final idx = _items.indexWhere((e) => e.id == product.id);
    if (idx >= 0) {
      _items[idx].name = product.name;
      _items[idx].imageName = product.imageName;
      _items[idx].category = product.category;
      _items[idx].description = product.description;
      _items[idx].price = product.price;
    }
  }
}
