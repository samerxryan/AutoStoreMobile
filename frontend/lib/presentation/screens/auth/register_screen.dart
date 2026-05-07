import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    for (final c in [_firstCtrl, _lastCtrl, _emailCtrl, _phoneCtrl, _passCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          firstName: _firstCtrl.text.trim(),
          lastName: _lastCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authProvider).error ?? 'Inscription échouée'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.car_repair, size: 52, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text('Créer un compte',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstCtrl,
                                  decoration: const InputDecoration(labelText: 'Prénom'),
                                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastCtrl,
                                  decoration: const InputDecoration(labelText: 'Nom'),
                                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                                ),
                              ),
                            ]),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                              validator: (v) => v!.contains('@') ? null : 'Email invalide',
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                  labelText: 'Téléphone (optionnel)',
                                  prefixIcon: Icon(Icons.phone_outlined)),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => v!.length >= 6 ? null : 'Min 6 caractères',
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _register,
                                child: auth.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    : const Text("S'inscrire"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Déjà un compte ? Se connecter',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
