import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/repositories/dish_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';

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
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.pickerTitle),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.of(context).pop(_selected.toList()),
            child: Text(l.pickerAddCount(_selected.length)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchBar(
              controller: _searchController,
              hintText: l.dishesSearchHint,
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
                          ? l.pickerEmptyCatalog
                          : l.dishesNoResults,
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
                          alreadyAdded ? Text(l.pickerAlreadyInDinner) : null,
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
