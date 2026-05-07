import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final cartCount = ref.watch(cartProvider.notifier).itemCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoParts TN', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('$cartCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _showProfileMenu(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Rechercher une pièce...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ),
      ),
      body: products.when(
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: 6,
          itemBuilder: (_, _) => const ProductCardSkeleton(),
        ),
        error: (e, _) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(e.toString()),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(productsProvider),
              child: const Text('Réessayer'),
            ),
          ]),
        ),
        data: (list) {
          final filtered = _search.isEmpty
              ? list
              : list.where((p) => p.name.toLowerCase().contains(_search)).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('Aucun produit trouvé'));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(productsProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) => ProductCard(
                product: filtered[i],
                onTap: () => context.push('/product/${filtered[i].id}'),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 1) context.push('/orders');
          if (i == 2) context.push('/quote');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Commandes'),
          NavigationDestination(icon: Icon(Icons.request_quote_outlined), selectedIcon: Icon(Icons.request_quote), label: 'Devis'),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.person_pin, size: 48),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ]),
      ),
    );
  }
}
