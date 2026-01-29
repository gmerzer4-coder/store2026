import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../../utils/app_colors.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({Key? key, required this.product, required this.onTap}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hover = false;

  Color _bgForCategory(String cat) {
    switch (cat) {
      case 'نسائي':
        return AppColors.feminine1;
      case 'شنط':
        return AppColors.leather4;
      case 'أحذية':
        return AppColors.leather3;
      case 'رجالي':
      default:
        return AppColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasImage = product.imageName.trim().isNotEmpty;
    final imgPath = hasImage ? 'assets/images/${product.imageName}.png' : null;
    final bg = _bgForCategory(product.category);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, _hover ? -8.0 : 0, 0),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _hover ? [BoxShadow(color: AppColors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 10))] : [],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Hero(
                      tag: product.id,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        child: imgPath != null
                            ? Image.asset(imgPath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]))
                            : Container(color: Colors.grey[200]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('${product.price.toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                      ],
                    ),
                  )
                ],
              ),
              Positioned(
                right: 8,
                top: 8,
                child: PopupMenuButton<String>(
                  onSelected: (v) async {
                    final prov = Provider.of<ProductProvider>(context, listen: false);
                    if (v == 'edit') {
                      final nameCtrl = TextEditingController(text: product.name);
                      final imgCtrl = TextEditingController(text: product.imageName);
                      final descCtrl = TextEditingController(text: product.description);
                      final priceCtrl = TextEditingController(text: product.price.toString());
                      String category = product.category;

                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('تعديل المنتج'),
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
                                final updated = Product(
                                  id: product.id,
                                  name: nameCtrl.text.trim(),
                                  imageName: imgCtrl.text.trim(),
                                  category: category,
                                  description: descCtrl.text.trim(),
                                  price: double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                                );
                                Navigator.of(ctx).pop();
                                try {
                                  await prov.updateProduct(updated);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التحديث')));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                                }
                              },
                              child: const Text('حفظ'),
                            )
                          ],
                        ),
                      );
                    } else if (v == 'delete') {
                      final ok = await showDialog<bool>(
                            context: context,
                            builder: (dctx) => AlertDialog(
                              title: const Text('حذف المنتج'),
                              content: const Text('هل انت متأكد أنك تريد حذف هذا المنتج؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('إلغاء')),
                                ElevatedButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('حذف')),
                              ],
                            ),
                          ) ??
                          false;
                      if (ok) {
                        try {
                          await prov.deleteProduct(product.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                        }
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    PopupMenuItem(value: 'delete', child: Text('حذف')),
                  ],
                  icon: const Icon(Icons.more_vert, size: 22, color: Colors.black87),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

