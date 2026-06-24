import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/repositories/tag_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';

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

  Future<void> _addTag() async {
    final l = AppLocalizations.of(context);
    final name = await _promptName(title: l.tagsNewCourse);
    if (name != null && name.isNotEmpty) {
      await _repo.create(name: name, group: TagGroup.portata);
    }
  }

  Future<void> _rename(Tag tag) async {
    final l = AppLocalizations.of(context);
    final name = await _promptName(title: l.tagsRename, initial: tag.name);
    if (name != null && name.isNotEmpty && name != tag.name) {
      await _repo.rename(tag.id, name);
    }
  }

  Future<void> _delete(Tag tag) async {
    final ok = await _repo.deleteIfUnused(tag.id);
    if (!mounted) return;
    if (!ok) {
      final l = AppLocalizations.of(context);
      final count = await _repo.usageCount(tag.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.tagsInUse(tag.name, count))),
      );
    }
  }

  Future<String?> _promptName({required String title, String? initial}) {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.tagsTitle)),
      body: ListView(
        children: [
          _GroupHeader(
            label: l.tagsCourses,
            onAdd: _addTag,
          ),
          _TagList(
            stream: _repo.watchByGroup(TagGroup.portata),
            onRename: _rename,
            onDelete: _delete,
            emptyHint: l.tagsEmptyHint,
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
    final l = AppLocalizations.of(context);
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
            tooltip: l.add,
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
