import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/repositories/ingredient_repository.dart';
import '../app_scope.dart';
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
    // Solo doppioni con la stessa unità e stesso tipo q.b. (FR-18).
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestione ingredienti')),
      body: StreamBuilder<List<Ingredient>>(
        stream: _repo.watchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Text('Nessun ingrediente.\nTocca + per aggiungerne uno.',
                  textAlign: TextAlign.center),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final ing = items[i];
              return ListTile(
                title: Text(ing.name),
                subtitle: Text(ing.isQb ? 'quanto basta' : ing.unit),
                trailing: ing.isQb
                    ? const Icon(Icons.all_inclusive, size: 18)
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
            subtitle: Text(ingredient.isQb ? 'quanto basta' : ingredient.unit),
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
