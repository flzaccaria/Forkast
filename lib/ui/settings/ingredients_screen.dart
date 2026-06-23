import 'package:flutter/material.dart';

import '../../core/reparto.dart';
import '../../core/unit.dart';
import '../../data/database.dart';
import '../../data/repositories/ingredient_repository.dart';
import '../app_scope.dart';
import '../theme.dart';
import '../widgets/forkast_app_bar.dart';
import 'ingredient_form.dart';

/// Ingredients catalog tab (FR-23): grouped by department, sortable by name.
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
    final created = await showIngredientForm(context, repo: _repo);
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrediente aggiunto')),
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
    final dishes = await _repo.dishesUsing(ing.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('"${ing.name}" — dove è usato'),
        content: dishes.isEmpty
            ? const Text('Non è usato in nessun piatto.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final d in dishes) Text('• $d')],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(Ingredient ing) async {
    final ok = await _repo.deleteIfUnused(ing.id);
    if (!ok) {
      final dishes = await _repo.dishesUsing(ing.id);
      _snack('"${ing.name}" è usato in ${dishes.length} piatti: '
          'rimuovilo prima da quei piatti.');
    } else {
      _snack('"${ing.name}" eliminato.');
    }
  }

  Future<void> _merge(Ingredient source) async {
    final all = await _repo.watchAll().first;
    final candidates = all
        .where((i) =>
            i.id != source.id && i.unit == source.unit && i.isQb == source.isQb)
        .toList();
    if (!mounted) return;
    if (candidates.isEmpty) {
      _snack('Nessun ingrediente con la stessa unità da unire.');
      return;
    }
    final target = await showDialog<Ingredient>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Unisci "${source.name}" in…'),
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
        ? '"${source.name}" unito in "${target.name}".'
        : 'Unione non riuscita: le unità devono coincidere.');
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
        entries.add(_RepartoHeader(label));
        currentLabel = label;
      }
      entries.add(_RepartoItem(item));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
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
                      'Nessun ingrediente ancora.\n'
                      'Tocca + per aggiungere il primo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tokens.inkMuted, fontSize: 15),
                    ),
                  ],
                ),
              ),
            );
          }
          final entries = _groupByReparto(items);
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final entry = entries[i];
              if (entry is _RepartoHeader) {
                return _StickyDepartmentHeader(label: entry.label);
              }
              final ing = (entry as _RepartoItem).ingredient;
              return ListTile(
                title: Text(ing.name),
                subtitle: Text(ing.isQb
                    ? 'quanto basta'
                    : Unit.tryParse(ing.unit)?.label ?? ing.unit),
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
  const _StickyDepartmentHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      color: tokens.surfacePage,
      child: Text(
        label.toUpperCase(),
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
  const _RepartoHeader(this.label);
  final String label;
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
    void run(VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(ingredient.name,
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(ingredient.isQb
                ? 'quanto basta'
                : Unit.tryParse(ingredient.unit)?.label ?? ingredient.unit),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modifica'),
            onTap: () => run(onEdit),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Dove è usato'),
            onTap: () => run(onShowUsage),
          ),
          ListTile(
            leading: const Icon(Icons.merge_type),
            title: const Text('Unisci doppione'),
            onTap: () => run(onMerge),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Elimina'),
            onTap: () => run(onDelete),
          ),
        ],
      ),
    );
  }
}
