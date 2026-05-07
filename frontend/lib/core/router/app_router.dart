import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/client/home_screen.dart';
import '../../presentation/screens/client/product_detail_screen.dart';
import '../../presentation/screens/client/cart_screen.dart';
import '../../presentation/screens/client/checkout_screen.dart';
import '../../presentation/screens/client/orders_screen.dart';
import '../../presentation/screens/client/quote_screen.dart';
import '../../presentation/screens/admin/admin_shell.dart';
import '../../presentation/screens/admin/dashboard_screen.dart';
import '../../presentation/screens/admin/admin_products_screen.dart';
import '../../presentation/screens/admin/admin_orders_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAdmin = authState.isAdmin;
      final going = state.matchedLocation;

      if (!isLoggedIn && going != '/login' && going != '/register') {
        return '/login';
      }
      if (isLoggedIn && (going == '/login' || going == '/register')) {
        return isAdmin ? '/admin/dashboard' : '/home';
      }
      // Admin trying to access client routes
      if (isLoggedIn && isAdmin && going.startsWith('/home')) {
        return '/admin/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),

      // ── Client routes ─────────────────────────────────────────────────────
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) =>
            ProductDetailScreen(productId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (_, _) => const CheckoutScreen()),
      GoRoute(path: '/orders', builder: (_, _) => const OrdersScreen()),
      GoRoute(path: '/quote', builder: (_, _) => const QuoteScreen()),

      // ── Admin routes ──────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin/dashboard', builder: (_, _) => const DashboardScreen()),
          GoRoute(path: '/admin/products', builder: (_, _) => const AdminProductsScreen()),
          GoRoute(path: '/admin/orders', builder: (_, _) => const AdminOrdersScreen()),
        ],
      ),
    ],
  );
});
