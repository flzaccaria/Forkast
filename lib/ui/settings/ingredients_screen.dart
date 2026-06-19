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
