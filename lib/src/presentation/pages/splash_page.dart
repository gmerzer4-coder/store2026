import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final AnimationController _swayCtrl;
  late final Animation<double> _sway;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.9, end: 1.05).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();

    _swayCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _sway = Tween<double>(begin: -0.035, end: 0.035).animate(CurvedAnimation(parent: _swayCtrl, curve: Curves.easeInOut));
    _swayCtrl.repeat(reverse: true);

    Timer(const Duration(milliseconds: 1800), () {
      // decide where to go: if Firebase initialized and no user -> login, else home
      final bool firebaseReady = Firebase.apps.isNotEmpty;
      if (firebaseReady && FirebaseAuth.instance.currentUser == null) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _swayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _sway,
                  builder: (ctx, child) => Transform.rotate(
                    angle: _sway.value,
                    child: child,
                  ),
                  child: Image.asset(
                    'assets/images/11.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.store, size: 64, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Luxe Store 2026 - متجر الأناقة للأحذية والحقائب',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
