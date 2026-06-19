import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/repositories/dish_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../app_scope.dart';
import '../widgets/settings_button.dart';
import 'dish_editor_screen.dart';

class DishesScreen extends StatefulWidget {
  const DishesScreen({super.key});

  @override
  State<DishesScreen> createState() => _DishesScreenState();
}

class _DishesScreenState extends State<DishesScreen> {
  late final DishRepository _repo;
  late final TagRepository _tagRepo;
  final _searchController = TextEditingController();
  String _query = '';
  String? _filterTagId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = DishRepository(scope.database, scope.householdId);
    _tagRepo = TagRepository(scope.database, scope.householdId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DishEditorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piatti'),
        actions: const [SettingsButton()],
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
          _TagFilterBar(
            tagRepo: _tagRepo,
            selectedTagId: _filterTagId,
            onSelected: (id) => setState(() => _filterTagId = id),
          ),
          Expanded(
            child: StreamBuilder<List<Dish>>(
              stream: _repo.watchAll(query: _query, tagId: _filterTagId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final dishes = snapshot.data!;
                if (dishes.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty
                          ? 'Nessun piatto.\nTocca + per crearne uno.'
                          : 'Nessun piatto trovato.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: dishes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) => ListTile(
                    title: Text(dishes[i].name),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Barra di filtri per tag (FR-15): scelta singola; "Tutti" azzera il filtro.
/// Si nasconde se non esistono tag.
class _TagFilterBar extends StatelessWidget {
  const _TagFilterBar({
    required this.tagRepo,
    required this.selectedTagId,
    required this.onSelected,
  });

  final TagRepository tagRepo;
  final String? selectedTagId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Tag>>(
      stream: tagRepo.watchAll(),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? const [];
        if (tags.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Tutti'),
                  selected: selectedTagId == null,
                  onSelected: (_) => onSelected(null),
                ),
              ),
              for (final tag in tags)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tag.name),
                    selected: selectedTagId == tag.id,
                    onSelected: (sel) => onSelected(sel ? tag.id : null),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
