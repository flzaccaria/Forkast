import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/repositories/dish_repository.dart';
import '../../data/repositories/ingredient_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../app_scope.dart';
import '../settings/ingredient_form.dart';

/// Dish editor: name + ingredient rows in base 4 (FR-2) + tags (FR-14).
/// For "quanto basta" ingredients the quantity is not required (FR-6).
/// When [dishId] is set it works in edit mode, preloading the existing data.
class DishEditorScreen extends StatefulWidget {
  const DishEditorScreen({super.key, this.dishId});

  final String? dishId;

  @override
  State<DishEditorScreen> createState() => _DishEditorScreenState();
}

class _DishEditorScreenState extends State<DishEditorScreen> {
  late final DishRepository _dishRepo;
  late final IngredientRepository _ingredientRepo;
  late final TagRepository _tagRepo;

  final _nameController = TextEditingController();
  final _rows = <_IngredientRow>[];
  String? _portataId;
  final _attributeIds = <String>{};
  bool _saving = false;
  bool _loading = false;
  bool _loaded = false;

  bool get _isEditing => widget.dishId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _dishRepo = DishRepository(scope.database, scope.householdId);
    _ingredientRepo = IngredientRepository(scope.database, scope.householdId);
    _tagRepo = TagRepository(scope.database, scope.householdId);
    if (_isEditing && !_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final dishId = widget.dishId!;
    final dish = await _dishRepo.getDish(dishId);
    final rows = await _dishRepo.getIngredients(dishId);
    final catalog = {for (final i in await _ingredientRepo.watchAll().first) i.id: i};
    final tags = await _tagRepo.watchDishTags(dishId).first;
    if (!mounted) return;
    setState(() {
      _nameController.text = dish?.name ?? '';
      for (final r in rows) {
        final ing = catalog[r.ingredientId];
        if (ing == null) continue; // ingredient removed from the catalog
        _rows.add(_IngredientRow(
          ingredient: ing,
          qtyController: TextEditingController(
            text: r.qtyBase4 == null
                ? ''
                : (r.qtyBase4 == r.qtyBase4!.roundToDouble()
                    ? r.qtyBase4!.toInt().toString()
                    : r.qtyBase4!.toString()),
          ),
        ));
      }
      for (final t in tags) {
        if (t.tagGroup == TagGroup.portata) {
          _portataId = t.id;
        } else {
          _attributeIds.add(t.id);
        }
      }
      _loading = false;
    });
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

    final tagIds = <String>[
      if (_portataId != null) _portataId!,
      ..._attributeIds,
    ];

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await _dishRepo.update(widget.dishId!,
            name: name, ingredients: drafts, tagIds: tagIds);
      } else {
        await _dishRepo.create(
            name: name, ingredients: drafts, tagIds: tagIds);
      }
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

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare il piatto?'),
        content: const Text(
            'Verrà rimosso dal catalogo e da tutte le serate in cui è '
            'pianificato. Le liste già generate si aggiornano alla prossima '
            'rigenerazione.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _saving = true);
    try {
      await _dishRepo.delete(widget.dishId!);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nell\'eliminazione del piatto')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifica piatto')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica piatto' : 'Nuovo piatto'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
              tooltip: 'Elimina',
            ),
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
          _TagSection(
            tagRepo: _tagRepo,
            portataId: _portataId,
            attributeIds: _attributeIds,
            onPortataChanged: (id) => setState(() => _portataId = id),
            onAttributeToggled: (id, selected) => setState(() {
              if (selected) {
                _attributeIds.add(id);
              } else {
                _attributeIds.remove(id);
              }
            }),
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

/// Dish tag selection (FR-14): one portata (single choice, optional) and
/// multiple attributes. The vocabulary is curated in the settings; here it is
/// only selected.
class _TagSection extends StatelessWidget {
  const _TagSection({
    required this.tagRepo,
    required this.portataId,
    required this.attributeIds,
    required this.onPortataChanged,
    required this.onAttributeToggled,
  });

  final TagRepository tagRepo;
  final String? portataId;
  final Set<String> attributeIds;
  final ValueChanged<String?> onPortataChanged;
  final void Function(String id, bool selected) onAttributeToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Portata', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        StreamBuilder<List<Tag>>(
          stream: tagRepo.watchByGroup(TagGroup.portata),
          builder: (context, snapshot) {
            final tags = snapshot.data ?? const [];
            if (tags.isEmpty) {
              return const _NoTagsHint();
            }
            return Wrap(
              spacing: 8,
              children: [
                for (final tag in tags)
                  ChoiceChip(
                    label: Text(tag.name),
                    selected: portataId == tag.id,
                    onSelected: (sel) =>
                        onPortataChanged(sel ? tag.id : null),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text('Attributi', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        StreamBuilder<List<Tag>>(
          stream: tagRepo.watchByGroup(TagGroup.attributo),
          builder: (context, snapshot) {
            final tags = snapshot.data ?? const [];
            if (tags.isEmpty) {
              return const _NoTagsHint();
            }
            return Wrap(
              spacing: 8,
              children: [
                for (final tag in tags)
                  FilterChip(
                    label: Text(tag.name),
                    selected: attributeIds.contains(tag.id),
                    onSelected: (sel) => onAttributeToggled(tag.id, sel),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NoTagsHint extends StatelessWidget {
  const _NoTagsHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Nessun tag definito. Aggiungili in Impostazioni → Tag dei piatti.',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

/// Ingredient picker from the shared catalog (FR-3, 4, 5). At the top it offers
/// "Crea nuovo ingrediente" to add an entry on the fly (FR-4, 5, 6) without
/// leaving the editor; the created entry is selected immediately.
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
