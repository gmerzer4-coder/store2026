import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/product_card.dart';
import '../../domain/entities/product.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _testRun = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runFirestoreTestIfNeeded();
    });
  }

  Future<void> _runFirestoreTestIfNeeded() async {
    if (_testRun) return;
    _testRun = true;
    final scaffold = ScaffoldMessenger.of(context);
    try {
      scaffold.showSnackBar(const SnackBar(content: Text('بدء اختبار Firebase: إضافة منتج')));
      print('Firebase Test: starting add');
      final col = FirebaseFirestore.instance.collection('products');
      final docRef = await col.add({
        'name': 'منتج اختبار - Temp',
        'imageName': '99',
        'category': 'اختبار',
        'description': 'وصف اختبار CRUD',
        'price': 0.01,
      });
      print('Firebase Test: added doc ${docRef.id}');
      scaffold.showSnackBar(SnackBar(content: Text('تمت إضافة منتج اختبار (id: ${docRef.id})')));

      await Future.delayed(const Duration(seconds: 2));

      scaffold.showSnackBar(const SnackBar(content: Text('جاري حذف منتج الاختبار...')));
      await col.doc(docRef.id).delete();
      print('Firebase Test: deleted doc ${docRef.id}');
      scaffold.showSnackBar(const SnackBar(content: Text('تم حذف منتج الاختبار بنجاح')));
    } catch (e, st) {
      print('Firebase Test: error $e');
      print(st);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ أثناء اختبار Firebase: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المتجر'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'اختبار Firebase',
            onPressed: () => _runFirestoreTestIfNeeded(),
            icon: const Icon(Icons.bug_report),
          ),
          IconButton(
            tooltip: 'إضافة منتج',
            onPressed: () => _showAddDialog(context, provider),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              try {
                final a = Provider.of<AuthProvider>(context, listen: false);
                await a.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ عند تسجيل الخروج: $e')));
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: () => provider.load(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: provider.items.length,
            itemBuilder: (context, i) {
              final p = provider.items[i];
              return ProductCard(
                product: p,
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage(product: p)));
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, provider),
        backgroundColor: AppColors.roseGold,
        foregroundColor: AppColors.black,
        label: const Text('إضافة'),
        icon: const Icon(Icons.add),
        tooltip: 'إضافة منتج',
      ),
    );
  }

  void _showAddDialog(BuildContext context, ProductProvider provider) {
    final nameCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String category = 'رجالي';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة منتج'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المنتج')),
              TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'اسم الصورة (مثال: 11)')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'الوصف')),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
              DropdownButtonFormField<String>(
                value: category,
                items: const [
                  DropdownMenuItem(value: 'رجالي', child: Text('رجالي')),
                  DropdownMenuItem(value: 'نسائي', child: Text('نسائي')),
                  DropdownMenuItem(value: 'شنط', child: Text('شنط')),
                  DropdownMenuItem(value: 'أحذية', child: Text('أحذية')),
                ],
                onChanged: (v) => category = v ?? category,
                decoration: const InputDecoration(labelText: 'التصنيف'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.addProduct(
                  nameCtrl.text.trim(),
                  imgCtrl.text.trim(),
                  category,
                  description: descCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                );
                Navigator.of(ctx).pop();
              } catch (e) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
