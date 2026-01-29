import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class DetailPage extends StatefulWidget {
  final Product product;
  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final Animation<double> _tiltAnim;

  @override
  void initState() {
    super.initState();
    // slow swaying/tilt animation for image '30' (very slow, subtle)
    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _tiltAnim = Tween<double>(begin: -0.02, end: 0.02).animate(CurvedAnimation(parent: _rotateCtrl, curve: Curves.easeInOut));
    if (widget.product.imageName.trim() == '30') {
      _rotateCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.product.imageName.trim().isNotEmpty;
    final imgPath = hasImage ? 'assets/images/${widget.product.imageName}.png' : null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Hero(
              tag: widget.product.id,
              child: SizedBox(
                width: 420,
                height: 420,
                child: widget.product.imageName.trim() == '30'
                    ? AnimatedBuilder(
                        animation: _tiltAnim,
                        builder: (context, child) {
                          final angle = _tiltAnim.value; // small tilt
                          return Transform.rotate(angle: angle, child: child);
                        },
                        child: imgPath != null
                            ? Image.asset(imgPath, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 96))
                            : const Icon(Icons.image_not_supported, size: 96),
                      )
                    : (imgPath != null
                        ? Image.asset(imgPath, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 96))
                        : const Icon(Icons.image_not_supported, size: 96)),
              ),
            ),
            const SizedBox(height: 24),
            Text(widget.product.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('التصنيف: ${widget.product.category}'),
          ],
        ),
      ),
    );
  }
}
