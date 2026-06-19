import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/repositories/ingredient_repository.dart';

/// Bottom sheet per creare una nuova voce di catalogo (FR-4, 5, 6).
/// Riusabile sia dalla gestione ingredienti sia dall'editor piatto
/// ("crea nuovo" al volo). Restituisce l'[Ingredient] creato, o null se
/// l'utente annulla.
Future<Ingredient?> showIngredientForm(
  BuildContext context, {
  required IngredientRepository repo,
  String? initialName,
}) {
  return showModalBottomSheet<Ingredient>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _IngredientForm(repo: repo, initialName: initialName),
  );
}

class _IngredientForm extends StatefulWidget {
  const _IngredientForm({required this.repo, this.initialName});

  final IngredientRepository repo;
  final String? initialName;

  @override
  State<_IngredientForm> createState() => _IngredientFormState();
}

class _IngredientFormState extends State<_IngredientForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController =
      TextEditingController(text: widget.initialName ?? '');
  final _unitController = TextEditingController();
  bool _isQb = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final created = await widget.repo.create(
        name: _nameController.text.trim(),
        // Per i "quanto basta" l'unità non è rilevante: la normalizziamo.
        unit: _isQb ? 'q.b.' : _unitController.text.trim(),
        isQb: _isQb,
      );
      if (mounted) Navigator.of(context).pop(created);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Errore: esiste già un ingrediente con questo nome?')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nuovo ingrediente',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _unitController,
              enabled: !_isQb,
              decoration: const InputDecoration(
                labelText: 'Unità (es. g, ml, pz)',
              ),
              validator: (v) {
                if (_isQb) return null;
                return (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null;
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Quanto basta'),
              subtitle: const Text('Senza quantità, non riscalato'),
              value: _isQb,
              onChanged: (v) => setState(() => _isQb = v),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }
}
