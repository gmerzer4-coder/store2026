import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLoading = false;

  late final AnimationController _bulbCtrl;
  late final AnimationController _formCtrl;
  late final Animation<double> _glow;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _bulbCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _formCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _glow = CurvedAnimation(parent: _bulbCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _bulbCtrl.dispose();
    _formCtrl.dispose();
    super.dispose();
  }

  Future<void> _onBulbTap() async {
    try {
      await _bulbCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 220));
      setState(() => _showForm = true);
      await _formCtrl.forward();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Bulb at top center
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: Center(
                child: GestureDetector(
                  onTap: _onBulbTap,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.06).animate(_glow),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FadeTransition(
                          opacity: _glow,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.feminine3.withOpacity(0.06),
                              boxShadow: [
                                BoxShadow(color: AppColors.feminine3.withOpacity(0.28), blurRadius: 40 * _glow.value, spreadRadius: 10 * _glow.value),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.lightbulb, size: 72, color: AppColors.feminine4),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Center large luxurious login form only (no images)
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _formCtrl,
                  builder: (ctx, child) {
                    final scale = 0.8 + 0.2 * _formCtrl.value;
                    final opacity = _formCtrl.value;
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(scale: scale, child: child),
                    );
                  },
                  child: _showForm
                      ? SizedBox(
                          width: 680,
                          child: Card(
                            color: AppColors.white,
                            elevation: 28,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('تسجيل الدخول', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.black)),
                                  const SizedBox(height: 14),
                                  TextField(controller: _email, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
                                  const SizedBox(height: 12),
                                  TextField(controller: _pass, decoration: const InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
                                  const SizedBox(height: 20),
                                  _isLoading
                                      ? const CircularProgressIndicator()
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(onPressed: () => _signIn(auth), child: const Text('دخول')),
                                            const SizedBox(width: 12),
                                            OutlinedButton(onPressed: () => _signUp(auth), child: const Text('إنشاء حساب')),
                                          ],
                                        )
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn(AuthProvider auth) async {
    setState(() => _isLoading = true);
    try {
      await auth.signIn(_email.text.trim(), _pass.text.trim());
      Navigator.of(context).pushReplacementNamed('/showcase');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp(AuthProvider auth) async {
    setState(() => _isLoading = true);
    try {
      await auth.signUp(_email.text.trim(), _pass.text.trim());
      Navigator.of(context).pushReplacementNamed('/showcase');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
