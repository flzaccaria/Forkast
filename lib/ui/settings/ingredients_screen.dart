import 'package:flutter/material.dart';

import '../../core/display_name.dart';
import '../../core/l10n_enums.dart';
import '../../core/reparto.dart';
import '../../core/unit.dart';
import '../../data/database.dart';
import '../../data/repositories/ingredient_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../theme.dart';
import '../widgets/forkast_app_bar.dart';
import 'ingredient_form.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  late final IngredientRepository _repo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = IngredientRepository(scope.database, scope.householdId);
  }

  Future<void> _addIngredient() async {
    final l = AppLocalizations.of(context);
    final created = await showIngredientForm(context, repo: _repo);
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.ingredientsAdded)),
      );
    }
  }

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _openActions(Ingredient ing) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => _IngredientActions(
        ingredient: ing,
        onEdit: () => _edit(ing),
        onShowUsage: () => _showUsage(ing),
        onDelete: () => _delete(ing),
        onMerge: () => _merge(ing),
      ),
    );
  }

  Future<void> _edit(Ingredient ing) async {
    await showIngredientForm(context, repo: _repo, existing: ing);
  }

  Future<void> _showUsage(Ingredient ing) async {
    final l = AppLocalizations.of(context);
    final dishes = await _repo.dishesUsing(ing.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.ingredientsUsageTitle(ing.name)),
        content: dishes.isEmpty
            ? Text(l.ingredientsNotUsed)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final d in dishes) Text('• $d')],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(Ingredient ing) async {
    final l = AppLocalizations.of(context);
    final ok = await _repo.deleteIfUnused(ing.id);
    if (!ok) {
      final dishes = await _repo.dishesUsing(ing.id);
      _snack(l.ingredientsUsedInCount(ing.name, dishes.length));
    } else {
      _snack(l.ingredientsDeleted(ing.name));
    }
  }

  Future<void> _merge(Ingredient source) async {
    final l = AppLocalizations.of(context);
    final all = await _repo.watchAll().first;
    final candidates = all
        .where((i) =>
            i.id != source.id && i.unit == source.unit && i.isQb == source.isQb)
        .toList();
    if (!mounted) return;
    if (candidates.isEmpty) {
      _snack(l.ingredientsNoMergeCandidates);
      return;
    }
    final target = await showDialog<Ingredient>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.ingredientsMergeTitle(source.name)),
        children: [
          for (final c in candidates)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(c),
              child: Text(c.name),
            ),
        ],
      ),
    );
    if (target == null) return;
    final ok = await _repo.merge(sourceId: source.id, targetId: target.id);
    _snack(ok
        ? l.ingredientsMergeSuccess(source.name, target.name)
        : l.ingredientsMergeError);
  }

  List<_RepartoEntry> _groupByReparto(List<Ingredient> items) {
    final sorted = [...items]..sort((a, b) {
        final byReparto = repartoSortIndex(a.category)
            .compareTo(repartoSortIndex(b.category));
        return byReparto != 0 ? byReparto : a.name.compareTo(b.name);
      });
    final entries = <_RepartoEntry>[];
    String? currentLabel;
    for (final item in sorted) {
      final label = item.category ?? repartoNonAssegnato;
      if (label != currentLabel) {
        entries.add(_RepartoHeader(label, item.category));
        currentLabel = label;
      }
      entries.add(_RepartoItem(item));
    }
    return entries;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return Scaffold(
      appBar: forkastAppBar(context),
      body: StreamBuilder<List<Ingredient>>(
        stream: _repo.watchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.kitchen_outlined, size: 48,
                        color: tokens.inkMuted),
                    const SizedBox(height: 12),
                    Text(
                      l.ingredientsEmptyState,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tokens.inkMuted, fontSize: 15),
                    ),
                  ],
                ),
              ),
            );
          }
          final entries = _groupByReparto(items);
          final locale = Localizations.localeOf(context).toString();
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final entry = entries[i];
              if (entry is _RepartoHeader) {
                return _StickyDepartmentHeader(label: entry.label, dbKey: entry.dbKey);
              }
              final ing = (entry as _RepartoItem).ingredient;
              return ListTile(
                title: Text(ingredientDisplayName(ing, locale)),
                subtitle: Text(ing.isQb
                    ? l.quantoBasta
                    : Unit.tryParse(ing.unit)?.localizedLabel(l) ?? ing.unit),
                trailing: ing.isQb
                    ? const Icon(Icons.all_inclusive_outlined, size: 18)
                    : null,
                onTap: () => _openActions(ing),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addIngredient,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StickyDepartmentHeader extends StatelessWidget {
  const _StickyDepartmentHeader({required this.label, this.dbKey});

  final String label;
  final String? dbKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      color: tokens.surfacePage,
      child: Text(
        localizedReparto(dbKey, l).toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
          color: primary,
        ),
      ),
    );
  }
}

sealed class _RepartoEntry {
  const _RepartoEntry();
}

class _RepartoHeader extends _RepartoEntry {
  const _RepartoHeader(this.label, this.dbKey);
  final String label;
  final String? dbKey;
}

class _RepartoItem extends _RepartoEntry {
  const _RepartoItem(this.ingredient);
  final Ingredient ingredient;
}

class _IngredientActions extends StatelessWidget {
  const _IngredientActions({
    required this.ingredient,
    required this.onEdit,
    required this.onShowUsage,
    required this.onDelete,
    required this.onMerge,
  });

  final Ingredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onShowUsage;
  final VoidCallback onDelete;
  final VoidCallback onMerge;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    void run(VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(ingredientDisplayName(ingredient, locale),
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(ingredient.isQb
                ? l.quantoBasta
                : Unit.tryParse(ingredient.unit)?.localizedLabel(l) ?? ingredient.unit),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(l.edit),
            onTap: () => run(onEdit),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: Text(l.ingredientsUsage),
            onTap: () => run(onShowUsage),
          ),
          ListTile(
            leading: const Icon(Icons.merge_type),
            title: Text(l.ingredientsMergeDuplicate),
            onTap: () => run(onMerge),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l.delete),
            onTap: () => run(onDelete),
          ),
        ],
      ),
    );
  }
}
