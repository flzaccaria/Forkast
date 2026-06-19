import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/repositories/dish_repository.dart';
import '../../data/repositories/ingredient_repository.dart';
import '../app_scope.dart';
import '../settings/ingredient_form.dart';

/// Editor di un nuovo piatto: nome + righe ingrediente in base 4 (FR-2).
/// Per gli ingredienti "quanto basta" la quantità non è richiesta (FR-6).
class DishEditorScreen extends StatefulWidget {
  const DishEditorScreen({super.key});

  @override
  State<DishEditorScreen> createState() => _DishEditorScreenState();
}

class _DishEditorScreenState extends State<DishEditorScreen> {
  late final DishRepository _dishRepo;
  late final IngredientRepository _ingredientRepo;

  final _nameController = TextEditingController();
  final _rows = <_IngredientRow>[];
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _dishRepo = DishRepository(scope.database, scope.householdId);
    _ingredientRepo = IngredientRepository(scope.database, scope.householdId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final r in _rows) {
      r.qtyController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickIngredient() async {
    final catalog = await _ingredientRepo.watchAll().first;
    final alreadyUsed = _rows.map((r) => r.ingredient.id).toSet();
    final available =
        catalog.where((i) => !alreadyUsed.contains(i.id)).toList();

    if (!mounted) return;

    final selected = await showModalBottomSheet<Ingredient>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _IngredientPicker(
        ingredients: available,
        repo: _ingredientRepo,
      ),
    );
    if (selected != null) {
      setState(() {
        _rows.add(_IngredientRow(
          ingredient: selected,
          qtyController: TextEditingController(),
        ));
      });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci il nome del piatto')),
      );
      return;
    }

    final drafts = <DishIngredientDraft>[];
    for (final r in _rows) {
      if (r.ingredient.isQb) {
        drafts.add(DishIngredientDraft(
          ingredientId: r.ingredient.id,
          qtyBase4: null,
        ));
      } else {
        final qty = double.tryParse(r.qtyController.text.replaceAll(',', '.'));
        if (qty == null || qty <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Quantità non valida per ${r.ingredient.name}')),
          );
          return;
        }
        drafts.add(DishIngredientDraft(
          ingredientId: r.ingredient.id,
          qtyBase4: qty,
        ));
      }
    }

    setState(() => _saving = true);
    try {
      await _dishRepo.create(name: name, ingredients: drafts);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nel salvataggio del piatto')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo piatto'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Salva'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome del piatto'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ingredienti (per 4 persone)',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _pickIngredient,
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi'),
              ),
            ],
          ),
          if (_rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Nessun ingrediente aggiunto.'),
            ),
          for (final row in _rows) _buildRow(row),
        ],
      ),
    );
  }

  Widget _buildRow(_IngredientRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(row.ingredient.name)),
          if (row.ingredient.isQb)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('q.b.'),
            )
          else
            SizedBox(
              width: 110,
              child: TextField(
                controller: row.qtyController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  isDense: true,
                  suffixText: row.ingredient.unit,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() {
              row.qtyController.dispose();
              _rows.remove(row);
            }),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow {
  _IngredientRow({required this.ingredient, required this.qtyController});

  final Ingredient ingredient;
  final TextEditingController qtyController;
}

/// Selettore ingrediente dal catalogo condiviso (FR-3, 4, 5). In cima offre
/// "Crea nuovo ingrediente" per aggiungere una voce al volo (FR-4, 5, 6) senza
/// uscire dall'editor; la voce creata viene selezionata immediatamente.
class _IngredientPicker extends StatelessWidget {
  const _IngredientPicker({required this.ingredients, required this.repo});

  final List<Ingredient> ingredients;
  final IngredientRepository repo;

  Future<void> _createNew(BuildContext context) async {
    final created = await showIngredientForm(context, repo: repo);
    if (created != null && context.mounted) {
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Crea nuovo ingrediente'),
            onTap: () => _createNew(context),
          ),
          const Divider(height: 1),
          if (ingredients.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Text(
                'Il catalogo è vuoto. Crea il primo ingrediente.',
                textAlign: TextAlign.center,
              ),
            )
          else
            for (final ing in ingredients)
              ListTile(
                title: Text(ing.name),
                subtitle: Text(ing.isQb ? 'quanto basta' : ing.unit),
                onTap: () => Navigator.of(context).pop(ing),
              ),
        ],
      ),
    );
  }
}
