class Product {
  final String id;
  String name;
  String imageName; // just the name, e.g. "11" -> assets/images/11.png
  String category; // رجالي / نسائي / شنط / أحذية
  String description;
  double price;

  Product({
    required this.id,
    required this.name,
    required this.imageName,
    required this.category,
    this.description = '',
    this.price = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'imageName': imageName,
        'category': category,
        'description': description,
        'price': price,
      };

  factory Product.fromMap(Map<String, dynamic> m) {
    return Product(
      id: m['id'] ?? '',
      name: m['name'] ?? '',
      imageName: m['imageName'] ?? '',
      category: m['category'] ?? '',
      description: m['description'] ?? '',
      price: (m['price'] is num) ? (m['price'] as num).toDouble() : double.tryParse('${m['price']}') ?? 0.0,
    );
  }
}
