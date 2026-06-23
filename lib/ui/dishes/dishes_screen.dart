import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/repositories/dish_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../app_scope.dart';
import '../theme.dart';
import '../widgets/forkast_app_bar.dart';
import 'confirm_delete_dish.dart';
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
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return Scaffold(
      appBar: forkastAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Cerca un piatto',
              leading: Icon(Icons.search, color: tokens.inkMuted),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          _TagFilterBar(
            tagRepo: _tagRepo,
            selectedTagId: _filterTagId,
            onSelected: (id) => setState(() => _filterTagId = id),
          ),
          Expanded(
            child: StreamBuilder<List<DishWithTags>>(
              stream: _repo.watchAllWithTags(
                  query: _query, tagId: _filterTagId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final dishes = snapshot.data!;
                if (dishes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _query.isEmpty
                            ? 'Nessun piatto ancora.\n'
                                'Tocca + per creare il primo.'
                            : 'Nessun piatto trovato.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: tokens.inkMuted),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: dishes.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 0.5,
                    indent: 20,
                    endIndent: 20,
                    color: tokens.border,
                  ),
                  itemBuilder: (context, i) {
                    final item = dishes[i];
                    return _DishRow(
                      dish: item.dish,
                      tags: item.tags,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              DishEditorScreen(dishId: item.dish.id),
                        ),
                      ),
                      onDismiss: () => confirmAndDeleteDish(
                        context,
                        repo: _repo,
                        dishId: item.dish.id,
                      ),
                    );
                  },
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

class _DishRow extends StatelessWidget {
  const _DishRow({
    required this.dish,
    required this.tags,
    required this.onTap,
    required this.onDismiss,
  });

  final Dish dish;
  final List<Tag> tags;
  final VoidCallback onTap;
  final Future<bool?> Function() onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return Dismissible(
      key: ValueKey(dish.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      confirmDismiss: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: tokens.ink,
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tags.map((tag) => _TagChip(tag: tag)).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tokens.inkMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    final color = tag.color != null
        ? Color(int.parse('FF${tag.color}', radix: 16))
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Text(
        tag.name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: tokens.ink,
        ),
      ),
    );
  }
}

/// Tag filter bar (FR-15): single choice; "Tutti" clears the filter.
/// Hidden when no tags exist.
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
