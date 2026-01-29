import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../../utils/app_colors.dart';
import 'detail_page.dart';

class ShowcasePage extends StatelessWidget {
  const ShowcasePage({Key? key}) : super(key: key);

  static const List<String> showcaseOrder = ['30','40','70','10','50','23','22','21','27','13','29','5','60','80','6'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final products = provider.items;
    final selected = showcaseOrder
        .map((id) => products.firstWhere((p) => p.imageName == id, orElse: () => Product(id: '', name: '', imageName: '', category: '', description: '', price: 0.0)))
        .where((p) => p.id.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Showcase - معرض الفخامة'),
        actions: [
          IconButton(
            tooltip: 'إضافة منتج',
            onPressed: () => _showAddDialog(context, provider),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: 0.78),
          itemCount: selected.length,
          itemBuilder: (ctx, i) {
            final p = selected[i];
            final bg = _bgForCategory(p.category);
            final hasImage = p.imageName.trim().isNotEmpty;
            final path = hasImage ? 'assets/images/${p.imageName}.png' : null;
            return _LuxuryCard(product: p, bg: bg, imagePath: path);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, provider),
        backgroundColor: const Color(0xFFB5828C),
        foregroundColor: Colors.white,
        tooltip: 'إضافة منتج',
        child: const Icon(Icons.add),
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

  Color _bgForCategory(String cat) {
    switch (cat) {
      case 'نسائي':
        return AppColors.feminine1;
      case 'شنط':
        return AppColors.leather4;
      case 'أحذية':
        return AppColors.leather3;
      default:
        return AppColors.white;
    }
  }
}

class _LuxuryCard extends StatefulWidget {
  final Product product;
  final Color bg;
  final String? imagePath;
  const _LuxuryCard({Key? key, required this.product, required this.bg, required this.imagePath}) : super(key: key);

  @override
  State<_LuxuryCard> createState() => _LuxuryCardState();
}

class _LuxuryCardState extends State<_LuxuryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage(product: p)));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          transform: Matrix4.translationValues(0, _hover ? -10.0 : 0, 0),
          decoration: BoxDecoration(color: widget.bg, borderRadius: BorderRadius.circular(18), boxShadow: _hover ? [BoxShadow(color: Colors.black26, blurRadius: 22, offset: const Offset(0, 12))] : []),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: widget.imagePath != null ? Image.asset(widget.imagePath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200])) : Container(color: Colors.grey[200]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('${p.price.toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
