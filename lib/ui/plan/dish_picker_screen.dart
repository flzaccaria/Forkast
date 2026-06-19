import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/repositories/dish_repository.dart';
import '../app_scope.dart';

/// Plan dish selection (FR-7): reuses the dish catalog in multiple-choice
/// mode. Returns the ids of the chosen dishes to add to the evening.
/// Already-assigned dishes are shown but disabled.
class DishPickerScreen extends StatefulWidget {
  const DishPickerScreen({super.key, this.alreadySelected = const []});

  final List<String> alreadySelected;

  @override
  State<DishPickerScreen> createState() => _DishPickerScreenState();
}

class _DishPickerScreenState extends State<DishPickerScreen> {
  late final DishRepository _repo;
  late final Set<String> _already = widget.alreadySelected.toSet();
  final _selected = <String>{};
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = DishRepository(scope.database, scope.householdId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi piatti'),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.of(context).pop(_selected.toList()),
            child: Text('Aggiungi (${_selected.length})'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Cerca un piatto',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Dish>>(
              stream: _repo.watchAll(query: _query),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final dishes = snapshot.data!;
                if (dishes.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty
                          ? 'Nessun piatto nel catalogo.'
                          : 'Nessun piatto trovato.',
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: dishes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final dish = dishes[i];
                    final alreadyAdded = _already.contains(dish.id);
                    return CheckboxListTile(
                      title: Text(dish.name),
                      subtitle:
                          alreadyAdded ? const Text('Già in questa cena') : null,
                      value: alreadyAdded || _selected.contains(dish.id),
                      onChanged: alreadyAdded
                          ? null
                          : (checked) => setState(() {
                                if (checked == true) {
                                  _selected.add(dish.id);
                                } else {
                                  _selected.remove(dish.id);
                                }
                              }),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
