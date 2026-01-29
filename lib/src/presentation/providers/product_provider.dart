import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/firestore_product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo;

  List<Product> _items = [];

  List<Product> get items => _items;

  ProductProvider({ProductRepository? repository}) : _repo = repository ?? FirestoreProductRepository() {
    load();
    _subscribeToFirestore();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _fireSub;

  void _subscribeToFirestore() {
    try {
      _fireSub = FirebaseFirestore.instance.collection('products').snapshots().listen((snap) {
        _items = snap.docs.map((d) => Product.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>})).toList();
        notifyListeners();
      }, onError: (_) {
        // ignore stream errors; fall back to manual load
      });
    } catch (_) {
      // Firebase may not be initialized in some contexts (tests); ignore subscription.
    }
  }

  StreamSubscription<QuerySnapshot>? _firestoreSub;

  Future<void> load() async {
    try {
      _items = await _repo.getAll();
      notifyListeners();
    } catch (e) {
      // keep app running; upper layers show errors
    }
  }

  Future<void> addProduct(String name, String imageName, String category, {String description = '', double price = 0.0}) async {
    // Optimistically add locally so UI updates immediately, then persist.
    final temp = Product(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, imageName: imageName, category: category, description: description, price: price);
    _items.insert(0, temp);
    notifyListeners();
    try {
      await _repo.add(Product(id: '', name: name, imageName: imageName, category: category, description: description, price: price));
      await load();
    } catch (e) {
      // revert optimistic change on error and rethrow so UI can show error
      _items.removeWhere((p) => p.id == temp.id);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(Product p) async {
    // Update locally first for immediate feedback, then persist.
    final idx = _items.indexWhere((it) => it.id == p.id);
    if (idx != -1) {
      _items[idx] = p;
      notifyListeners();
    }
    try {
      await _repo.update(p);
      await load();
    } catch (e) {
      // reload to restore authoritative state
      await load();
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    // Remove locally first for immediate feedback, then persist.
    final removed = _items.where((it) => it.id == id).toList();
    _items.removeWhere((it) => it.id == id);
    notifyListeners();
    try {
      await _repo.delete(id);
      await load();
    } catch (e) {
      // restore on error
      if (removed.isNotEmpty) {
        _items.insertAll(0, removed);
        notifyListeners();
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _fireSub?.cancel();
    _firestoreSub?.cancel();
    super.dispose();
  }
}
