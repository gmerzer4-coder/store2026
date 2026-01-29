import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/product.dart';
import '../domain/repositories/product_repository.dart';

class FirestoreProductRepository implements ProductRepository {
  final CollectionReference _col = FirebaseFirestore.instance.collection('products');

  @override
  Future<void> add(Product product) async {
    // store without id field; Firestore will generate an id
    final data = {
      'name': product.name,
      'imageName': product.imageName,
      'category': product.category,
      'description': product.description,
      'price': product.price,
    };
    await _col.add(data);
  }

  @override
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  @override
  Future<List<Product>> getAll() async {
    final snap = await _col.get();
    return snap.docs
      .map((d) => Product.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
      .toList();
  }

  @override
  Future<void> update(Product product) async {
    final doc = _col.doc(product.id);
    final data = {
      'name': product.name,
      'imageName': product.imageName,
      'category': product.category,
      'description': product.description,
      'price': product.price,
    };
    await doc.update(data);
  }
}
