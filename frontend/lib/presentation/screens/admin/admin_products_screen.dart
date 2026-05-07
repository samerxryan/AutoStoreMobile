import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/product_provider.dart';
import '../../../core/theme/app_theme.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});
  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  Future<void> _showCreateDialog() async {
    final categories = await ref.read(apiServiceProvider).getCategories();
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductFormSheet(categories: categories),
    ).then((_) => ref.invalidate(productsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    return Scaffold(
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (ctx, i) {
            final p = list[i];
            return ListTile(
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${p.price.toStringAsFixed(3)} TND | Stock: ${p.stockQuantity}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await ref.read(apiServiceProvider).deleteProduct(p.id);
                  ref.invalidate(productsProvider);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductFormSheet extends ConsumerStatefulWidget {
  final List<CategoryModel> categories;
  const _ProductFormSheet({required this.categories});

  @override
  ConsumerState<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<_ProductFormSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  int? _selectedCategory;
  XFile? _image;
  bool _loading = false;

  void _submit() async {
    setState(() => _loading = true);
    try {
      final formData = FormData.fromMap({
        'product': MultipartFile.fromString(
          '{"name":"${_nameCtrl.text}","description":"${_descCtrl.text}","price":${_priceCtrl.text},"stockQuantity":${_stockCtrl.text},"categoryId":${_selectedCategory ?? 'null'}}',
          contentType: DioMediaType('application', 'json'),
        ),
      });

      if (_image != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(_image!.path, filename: _image!.name),
        ));
      }

      await ref.read(apiServiceProvider).createProduct(formData);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nouveau Produit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final xf = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (xf != null) setState(() => _image = xf);
              },
              child: Container(
                height: 120,
                color: Colors.grey[200],
                child: _image == null
                    ? const Center(child: Text('Sélectionner Image (Optionnelle)'))
                    : const Center(child: Icon(Icons.check, color: AppTheme.success, size: 48)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nom du produit')),
            const SizedBox(height: 12),
            TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix (TND)'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock initial'))),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: widget.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator() : const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}
