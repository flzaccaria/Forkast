import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/repositories/tag_repository.dart';
import '../app_scope.dart';

/// Management of the curated tag vocabulary (FR-14): portate and attributes.
/// Deletion is protected when the tag is in use (consistent with FR-17).
class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  late final TagRepository _repo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = TagRepository(scope.database, scope.householdId);
  }

  Future<void> _addTag(String group) async {
    final name = await _promptName(
      title: group == TagGroup.portata ? 'Nuova portata' : 'Nuovo attributo',
    );
    if (name != null && name.isNotEmpty) {
      await _repo.create(name: name, group: group);
    }
  }

  Future<void> _rename(Tag tag) async {
    final name = await _promptName(title: 'Rinomina', initial: tag.name);
    if (name != null && name.isNotEmpty && name != tag.name) {
      await _repo.rename(tag.id, name);
    }
  }

  Future<void> _delete(Tag tag) async {
    final ok = await _repo.deleteIfUnused(tag.id);
    if (!mounted) return;
    if (!ok) {
      final count = await _repo.usageCount(tag.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '"${tag.name}" è usato in $count piatti: rimuovilo prima da quei piatti.'),
        ),
      );
    }
  }

  Future<String?> _promptName({required String title, String? initial}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tag dei piatti')),
      body: ListView(
        children: [
          _GroupHeader(
            label: 'Portate',
            onAdd: () => _addTag(TagGroup.portata),
          ),
          _TagList(
            stream: _repo.watchByGroup(TagGroup.portata),
            onRename: _rename,
            onDelete: _delete,
            emptyHint: 'Nessuna portata. Esempi: Primo, Secondo, Contorno.',
          ),
          _GroupHeader(
            label: 'Attributi',
            onAdd: () => _addTag(TagGroup.attributo),
          ),
          _TagList(
            stream: _repo.watchByGroup(TagGroup.attributo),
            onRename: _rename,
            onDelete: _delete,
            emptyHint: 'Nessun attributo. Esempi: Veloce, Vegetariano, Pesce.',
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, required this.onAdd});

  final String label;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.8,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAdd,
            tooltip: 'Aggiungi',
          ),
        ],
      ),
    );
  }
}

class _TagList extends StatelessWidget {
  const _TagList({
    required this.stream,
    required this.onRename,
    required this.onDelete,
    required this.emptyHint,
  });

  final Stream<List<Tag>> stream;
  final ValueChanged<Tag> onRename;
  final ValueChanged<Tag> onDelete;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Tag>>(
      stream: stream,
      builder: (context, snapshot) {
        final tags = snapshot.data ?? const [];
        if (tags.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(emptyHint,
                style: Theme.of(context).textTheme.bodySmall),
          );
        }
        return Column(
          children: [
            for (final tag in tags)
              ListTile(
                leading: const Icon(Icons.label_outlined),
                title: Text(tag.name),
                onTap: () => onRename(tag),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onDelete(tag),
                ),
              ),
          ],
        );
      },
    );
  }
}
