import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/cart_provider.dart';
import '../../../data/services/api_service.dart';
import '../../../core/theme/app_theme.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isLoading = false;

  Future<void> _submitOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final items = cart
          .map((i) => {
                'productId': i.productId,
                'quantity': i.quantity,
              })
          .toList();

      await ref.read(apiServiceProvider).placeOrder(items);
      ref.read(cartProvider.notifier).clear();
      
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, size: 64, color: AppTheme.success),
          title: const Text('Commande confirmée !'),
          content: const Text(
            'Votre commande a été enregistrée avec succès. Paiement à la livraison.',
            textAlign: TextAlign.center,
          ),
          contentPadding: const EdgeInsets.all(24),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(); // close dialog
                  context.go('/orders');
                },
                child: const Text('Voir mes commandes'),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).total;

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: cart.isEmpty
          ? const Center(child: Text('Panier vide'))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.delivery_dining, size: 80, color: AppTheme.primary),
                const SizedBox(height: 16),
                const Text(
                  'Paiement à la livraison',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vous paierez le montant total directement au livreur lors de la réception de votre colis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 48),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Total à payer',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          '${total.toStringAsFixed(3)} TND',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitOrder,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Confirmer la commande'),
                  ),
                ),
              ),
            ),
    );
  }
}
