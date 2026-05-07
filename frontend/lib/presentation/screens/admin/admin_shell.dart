import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF023E8A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text('Administration', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Tableau de bord'),
              onTap: () {
                context.pop();
                context.go('/admin/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Produits & Stocks'),
              onTap: () {
                context.pop();
                context.go('/admin/products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Commandes'),
              onTap: () {
                context.pop();
                context.go('/admin/orders');
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
