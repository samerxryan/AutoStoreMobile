import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/services/api_service.dart';
import '../../../core/theme/app_theme.dart';

class QuoteScreen extends ConsumerStatefulWidget {
  const QuoteScreen({super.key});

  @override
  ConsumerState<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends ConsumerState<QuoteScreen> {
  final _ctrl = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(apiServiceProvider).requestQuote(msg);
      if (!mounted) return;
      _ctrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande de devis envoyée avec succès.'),
          backgroundColor: AppTheme.success,
        ),
      );
      context.go('/home');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Demander un devis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.request_quote_rounded, size: 80, color: AppTheme.primary),
            const SizedBox(height: 16),
            const Text(
              "Vous cherchez une pièce spécifique ?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Décrivez la pièce dont vous avez besoin (modèle de voiture, année, numéro de série si possible), et nous vous répondrons avec un devis personnalisé.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _ctrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Bonjour, je cherche un kit d\'embrayage pour Peugeot 208 année 2018...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: const Icon(Icons.send),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Envoyer la demande'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
