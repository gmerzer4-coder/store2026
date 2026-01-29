import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<void> add(Product product);
  Future<void> update(Product product);
  Future<void> delete(String id);
}
