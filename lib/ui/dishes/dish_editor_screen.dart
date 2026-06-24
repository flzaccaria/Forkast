import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/dish_enums.dart';
import '../../core/display_name.dart';
import '../../core/l10n_enums.dart';
import '../../core/qty_format.dart';
import '../../data/database.dart';
import '../../data/repositories/dish_repository.dart';
import '../../data/repositories/ingredient_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../theme.dart';
import '../settings/ingredient_form.dart';
import 'confirm_delete_dish.dart';

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
  Difficulty? _difficulty;
  TimeEstimate? _timeEstimate;
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

  String get _qtyLocale => Localizations.localeOf(context).toString();

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
      _difficulty = Difficulty.tryParse(dish?.difficulty);
      _timeEstimate = TimeEstimate.tryParse(dish?.timeEstimate);
      for (final r in rows) {
        final ing = catalog[r.ingredientId];
        if (ing == null) continue;
        _rows.add(_IngredientRow(
          ingredient: ing,
          qtyController: TextEditingController(
            text: r.qtyBase4 == null ? '' : formatQty(r.qtyBase4!, locale: _qtyLocale),
          ),
        ));
      }
      for (final t in tags) {
        if (t.tagGroup == TagGroup.portata) {
          _portataId = t.id;
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
    final l = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.dishEditorNameRequired)),
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
            SnackBar(content: Text(l.dishEditorInvalidQty(r.ingredient.name))),
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
    ];

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await _dishRepo.update(widget.dishId!,
            name: name,
            ingredients: drafts,
            tagIds: tagIds,
            difficulty: Value(_difficulty?.dbValue),
            timeEstimate: Value(_timeEstimate?.dbValue));
      } else {
        await _dishRepo.create(
            name: name,
            ingredients: drafts,
            tagIds: tagIds,
            difficulty: _difficulty?.dbValue,
            timeEstimate: _timeEstimate?.dbValue);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.dishEditorSaveError)),
        );
      }
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final deleted = await confirmAndDeleteDish(
        context,
        repo: _dishRepo,
        dishId: widget.dishId!,
      );
      if (deleted && mounted) {
        Navigator.of(context).pop();
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.dishEditorDeleteError)),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.dishEditorEditTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.dishEditorEditTitle : l.dishEditorNewTitle),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
              tooltip: l.delete,
            ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l.dishEditorNameLabel),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),

          _PortataSection(
            tagRepo: _tagRepo,
            portataId: _portataId,
            onPortataChanged: (id) => setState(() => _portataId = id),
          ),
          const SizedBox(height: 16),

          Text(l.dishEditorDifficulty, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final d in Difficulty.values)
                ChoiceChip(
                  label: Text(d.localizedLabel(l)),
                  selected: _difficulty == d,
                  onSelected: (sel) =>
                      setState(() => _difficulty = sel ? d : null),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Text(l.dishEditorTime, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final t in TimeEstimate.values)
                ChoiceChip(
                  label: Text(t.localizedLabel(l)),
                  selected: _timeEstimate == t,
                  onSelected: (sel) =>
                      setState(() => _timeEstimate = sel ? t : null),
                ),
            ],
          ),

          const SizedBox(height: 32),
          Divider(color: tokens.border, height: 0.5),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.dishEditorIngredients,
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _pickIngredient,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l.add),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l.dishEditorQuantitiesNote,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: tokens.inkMuted,
              ),
            ),
          ),
          if (_rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l.dishEditorNoIngredients,
                style: TextStyle(color: tokens.inkMuted),
              ),
            ),
          for (final row in _rows) _buildRow(row, tokens),
        ],
      ),
    );
  }

  Widget _buildRow(_IngredientRow row, ForkastTokens tokens) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              ingredientDisplayName(row.ingredient, locale),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: tokens.ink,
              ),
            ),
          ),
          if (row.ingredient.isQb)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tokens.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l.qb,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: tokens.inkMuted,
                ),
              ),
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
            icon: Icon(Icons.close, size: 18, color: tokens.inkMuted),
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

class _PortataSection extends StatelessWidget {
  const _PortataSection({
    required this.tagRepo,
    required this.portataId,
    required this.onPortataChanged,
  });

  final TagRepository tagRepo;
  final String? portataId;
  final ValueChanged<String?> onPortataChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.dishEditorCourse, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        StreamBuilder<List<Tag>>(
          stream: tagRepo.watchByGroup(TagGroup.portata),
          builder: (context, snapshot) {
            final tags = snapshot.data ?? const [];
            if (tags.isEmpty) {
              return Text(
                l.dishEditorNoCoursesDefined,
                style: Theme.of(context).textTheme.bodySmall,
              );
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
      ],
    );
  }
}

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
    final l = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l.dishEditorCreateIngredient),
            onTap: () => _createNew(context),
          ),
          Divider(height: 0.5, color: tokens.border),
          if (ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Text(
                l.dishEditorCatalogEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.inkMuted),
              ),
            )
          else
            for (final ing in ingredients)
              ListTile(
                title: Text(ingredientDisplayName(ing, Localizations.localeOf(context).toString())),
                subtitle: Text(ing.isQb ? l.quantoBasta : ing.unit),
                onTap: () => Navigator.of(context).pop(ing),
              ),
        ],
      ),
    );
  }
}
