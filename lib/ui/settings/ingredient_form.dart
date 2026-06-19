import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/reparto.dart';
import '../../data/database.dart';
import '../../data/repositories/ingredient_repository.dart';

/// Bottom sheet to create or edit a catalog entry (FR-4, 5, 6, 16).
/// Reusable from the ingredient management and the dish editor ("create new"
/// on the fly). In edit mode, if the ingredient is already used in a dish the
/// unit is locked (FR-16). Returns the saved [Ingredient], or null if cancelled.
Future<Ingredient?> showIngredientForm(
  BuildContext context, {
  required IngredientRepository repo,
  String? initialName,
  Ingredient? existing,
}) {
  return showModalBottomSheet<Ingredient>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _IngredientForm(
      repo: repo,
      initialName: initialName,
      existing: existing,
    ),
  );
}

class _IngredientForm extends StatefulWidget {
  const _IngredientForm({required this.repo, this.initialName, this.existing});

  final IngredientRepository repo;
  final String? initialName;
  final Ingredient? existing;

  @override
  State<_IngredientForm> createState() => _IngredientFormState();
}

class _IngredientFormState extends State<_IngredientForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
      text: widget.existing?.name ?? widget.initialName ?? '');
  late final _unitController = TextEditingController(
      text: widget.existing != null && !widget.existing!.isQb
          ? widget.existing!.unit
          : '');
  late bool _isQb = widget.existing?.isQb ?? false;
  late String? _category = widget.existing?.category;
  bool _saving = false;

  /// On creation the unit is always editable; in edit mode it is locked if
  /// the ingredient is already used (FR-16). Resolved in initState.
  bool _unitLocked = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      widget.repo.isUnitLocked(widget.existing!.id).then((locked) {
        if (mounted) setState(() => _unitLocked = locked);
      });
    }
  }

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
      final name = _nameController.text.trim();
      final unit = _isQb ? 'q.b.' : _unitController.text.trim();
      if (_isEditing) {
        await widget.repo.update(
          widget.existing!.id,
          name: name,
          // The unit is ignored by the repository when locked (FR-16).
          unit: unit,
          isQb: _unitLocked ? null : _isQb,
          category: Value(_category),
        );
        if (mounted) Navigator.of(context).pop(widget.existing);
      } else {
        final created = await widget.repo
            .create(name: name, unit: unit, isQb: _isQb, category: _category);
        if (mounted) Navigator.of(context).pop(created);
      }
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
    final unitEnabled = !_isQb && !_unitLocked;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_isEditing ? 'Modifica ingrediente' : 'Nuovo ingrediente',
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
              enabled: unitEnabled,
              decoration: InputDecoration(
                labelText: 'Unità (es. g, ml, pz)',
                helperText: _unitLocked
                    ? 'Bloccata: l\'ingrediente è già usato in un piatto'
                    : null,
              ),
              validator: (v) {
                if (_isQb || _unitLocked) return null;
                return (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null;
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Quanto basta'),
              subtitle: const Text('Senza quantità, non riscalato'),
              value: _isQb,
              onChanged: _unitLocked ? null : (v) => setState(() => _isQb = v),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Reparto',
                helperText: 'Ordina la lista della spesa per reparto',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text(repartoNonAssegnato),
                ),
                for (final r in reparti)
                  DropdownMenuItem<String?>(value: r, child: Text(r)),
              ],
              onChanged: (v) => setState(() => _category = v),
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
