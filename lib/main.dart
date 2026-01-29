import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/presentation/providers/product_provider.dart';
import 'src/presentation/pages/splash_page.dart';
import 'src/presentation/pages/home_page.dart';
import 'src/presentation/pages/login_page.dart';
import 'src/presentation/pages/showcase_page.dart';
import 'src/presentation/providers/auth_provider.dart';
import 'src/utils/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/data/firestore_product_repository.dart';
import 'src/data/in_memory_product_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseReady = false;
  try {
    // Initialize using generated options from `flutterfire configure` (web/ios/android)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    // If firebase_options.dart doesn't exist or initialization fails,
    // attempt a default initialize (if user added native configs) otherwise continue offline.
    try {
      await Firebase.initializeApp();
      firebaseReady = Firebase.apps.isNotEmpty;
    } catch (_) {
      firebaseReady = false;
    }
  }

  runApp(MyApp(firebaseEnabled: firebaseReady));
}

class MyApp extends StatelessWidget {
  final bool firebaseEnabled;
  const MyApp({super.key, required this.firebaseEnabled});

  @override
  Widget build(BuildContext context) {
    final repo = firebaseEnabled ? FirestoreProductRepository() : InMemoryProductRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider(repository: repo)),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Store2026',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.feminine3, foregroundColor: AppColors.black, textStyle: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.black, side: const BorderSide(color: Colors.black12)),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: AppColors.feminine3, foregroundColor: AppColors.black),
          useMaterial3: true,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black87),
          ),
        ),
        routes: {
          '/': (_) => const SplashPage(),
          '/login': (_) => const LoginPage(),
          '/home': (_) => const HomePage(),
          '/showcase': (_) => const ShowcasePage(),
        },
      ),
    );
  }
}
