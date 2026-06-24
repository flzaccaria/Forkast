import 'package:flutter/material.dart';

import '../../core/l10n_enums.dart';
import '../../core/qty_format.dart';
import '../../core/reparto.dart';
import '../../core/seed_name_resolver.dart';
import '../../core/week.dart';
import '../../data/database.dart';
import '../../data/repositories/list_repository.dart';
import '../../data/repositories/plan_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../theme.dart';
import '../widgets/forkast_app_bar.dart';

String _resolvedName(GeneratedItemView item, String locale) {
  return SeedNameResolver.instance.resolve(
    storedName: item.name,
    seedKey: item.seedKey,
    nameModified: item.nameModified,
    locale: locale,
  );
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late final ListRepository _repo;
  late final PlanRepository _planRepo;

  final _now = DateTime.now();
  int get _year => isoWeekYear(_now);
  int get _week => isoWeekNumber(_now);

  bool _generating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = ListRepository(scope.database, scope.householdId);
    _planRepo = PlanRepository(scope.database, scope.householdId);
  }

  Future<void> _generate(String weekPlanId) async {
    if (_generating) return;
    setState(() => _generating = true);
    try {
      await _repo.generate(weekPlanId);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return Scaffold(
      appBar: forkastAppBar(context),
      body: StreamBuilder<WeekPlan?>(
        stream: _planRepo.watchWeekPlan(_year, _week),
        builder: (context, planSnap) {
          final weekPlan = planSnap.data;
          if (weekPlan == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy_outlined, size: 48,
                        color: tokens.inkMuted),
                    const SizedBox(height: 12),
                    Text(
                      l.listEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tokens.inkMuted, fontSize: 15),
                    ),
                  ],
                ),
              ),
            );
          }
          return StreamBuilder<ShoppingList?>(
            stream: _repo.watchList(weekPlan.id),
            builder: (context, listSnap) {
              final list = listSnap.data;
              if (list == null) {
                _generate(weekPlan.id);
                return const Center(child: CircularProgressIndicator());
              }
              return _ListContent(
                repo: _repo,
                weekPlanId: weekPlan.id,
                list: list,
                generating: _generating,
                onRegenerate: () => _generate(weekPlan.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _ListContent extends StatefulWidget {
  const _ListContent({
    required this.repo,
    required this.weekPlanId,
    required this.list,
    required this.generating,
    required this.onRegenerate,
  });

  final ListRepository repo;
  final String weekPlanId;
  final ShoppingList list;
  final bool generating;
  final VoidCallback onRegenerate;

  @override
  State<_ListContent> createState() => _ListContentState();
}

class _ListContentState extends State<_ListContent> {
  @override
  void initState() {
    super.initState();
    _autoRegenIfNeeded();
  }

  @override
  void didUpdateWidget(_ListContent old) {
    super.didUpdateWidget(old);
    if (old.list.planHash != widget.list.planHash) {
      _autoRegenIfNeeded();
    }
  }

  Future<void> _autoRegenIfNeeded() async {
    final current = await widget.repo.currentPlanHash(widget.weekPlanId);
    if (current != widget.list.planHash) {
      widget.onRegenerate();
    }
  }

  Future<void> _addManual() async {
    final result = await showModalBottomSheet<_ManualDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ManualItemForm(),
    );
    if (result != null) {
      await widget.repo.addManualItem(
        widget.list.id,
        name: result.name,
        qty: result.qty,
        unit: result.unit,
      );
    }
  }

  Future<void> _editGenerated(GeneratedItemView item) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => _GeneratedRowActions(
        item: item,
        onEditQty: (qty) =>
            widget.repo.setOverrideQty(widget.list.id, item.ingredientId, qty),
        onRemove: () =>
            widget.repo.removeGeneratedRow(widget.list.id, item.ingredientId),
        onRestore: () => widget.repo
            .restoreGeneratedRow(widget.list.id, item.ingredientId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _GeneratedSection(
            repo: widget.repo,
            listId: widget.list.id,
            onTapRow: _editGenerated,
          ),
          _ManualSection(repo: widget.repo, listId: widget.list.id),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addManual,
        icon: const Icon(Icons.add),
        label: Text(l.listManualTitle),
      ),
    );
  }
}

class _GeneratedSection extends StatelessWidget {
  const _GeneratedSection({
    required this.repo,
    required this.listId,
    required this.onTapRow,
  });

  final ListRepository repo;
  final String listId;
  final ValueChanged<GeneratedItemView> onTapRow;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return StreamBuilder<List<GeneratedItemView>>(
      stream: repo.watchGeneratedItems(listId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )),
          );
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l.listGeneratedEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.inkMuted),
              ),
            ),
          );
        }
        final locale = Localizations.localeOf(context).toString();
        final entries = _groupByReparto(items, locale);
        return SliverList.builder(
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final entry = entries[i];
            if (entry is _RepartoHeader) {
              return _StickyDepartmentHeader(label: entry.label, dbKey: entry.dbKey);
            }
            final item = (entry as _RepartoItem).item;
            return _GeneratedRow(
              item: item,
              onCheck: (v) => repo.setIngredientChecked(
                  listId, item.ingredientId, v),
              onTap: () => onTapRow(item),
            );
          },
        );
      },
    );
  }

  List<_RepartoEntry> _groupByReparto(List<GeneratedItemView> items, String locale) {
    final sorted = [...items]..sort((a, b) {
        final byReparto = repartoSortIndex(a.category)
            .compareTo(repartoSortIndex(b.category));
        return byReparto != 0
            ? byReparto
            : _resolvedName(a, locale).compareTo(_resolvedName(b, locale));
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
}

class _StickyDepartmentHeader extends StatelessWidget {
  const _StickyDepartmentHeader({required this.label, this.dbKey});

  final String label;
  final String? dbKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    final primary = Theme.of(context).colorScheme.primary;
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

class _GeneratedRow extends StatelessWidget {
  const _GeneratedRow({
    required this.item,
    required this.onCheck,
    required this.onTap,
  });

  final GeneratedItemView item;
  final ValueChanged<bool> onCheck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    final checked = item.checked;
    final removed = item.removed;
    final dimmed = checked || removed;
    final nameColor = dimmed ? tokens.inkMuted : tokens.ink;
    final nameDecoration =
        checked ? TextDecoration.lineThrough : TextDecoration.none;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: removed ? null : (v) => onCheck(v ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resolvedName(item, locale),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: nameColor,
                      decoration: nameDecoration,
                    ),
                  ),
                  if (item.hasOverride && !removed)
                    Text(l.listModified,
                        style: TextStyle(
                            fontSize: 12, color: tokens.inkMuted)),
                  if (removed)
                    Text(l.listRemoved,
                        style: TextStyle(
                            fontSize: 12, color: tokens.inkMuted)),
                ],
              ),
            ),
            _QtyLabel(item: item, dimmed: dimmed),
          ],
        ),
      ),
    );
  }
}

class _QtyLabel extends StatelessWidget {
  const _QtyLabel({required this.item, required this.dimmed});

  final GeneratedItemView item;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    if (item.isQb) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: tokens.border.withValues(alpha: dimmed ? 0.3 : 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          l.qb,
          style: TextStyle(
            fontSize: 13,
            color: dimmed
                ? tokens.inkMuted.withValues(alpha: 0.5)
                : tokens.inkMuted,
          ),
        ),
      );
    }
    final qty = item.displayQty;
    if (qty == null) return const SizedBox.shrink();
    return Text(
      '${formatQty(qty, locale: locale)} ${item.unit}',
      style: TextStyle(
        fontSize: 13,
        color: dimmed ? tokens.inkMuted.withValues(alpha: 0.5) : tokens.inkMuted,
        decoration: item.checked ? TextDecoration.lineThrough : null,
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
  const _RepartoItem(this.item);
  final GeneratedItemView item;
}

class _ManualSection extends StatelessWidget {
  const _ManualSection({required this.repo, required this.listId});

  final ListRepository repo;
  final String listId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return StreamBuilder<List<ManualItemView>>(
      stream: repo.watchManualItems(listId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter();
        }
        final items = snapshot.data!;
        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
                color: tokens.surfacePage,
                child: Row(
                  children: [
                    Text(
                      l.listManualAdds,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l.listManualBadge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                height: 0.5,
                indent: 20,
                endIndent: 20,
                color: tokens.border,
              ),
              itemBuilder: (context, i) {
                final item = items[i];
                final checked = item.checked;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Row(
                    children: [
                      Checkbox(
                        value: checked,
                        onChanged: (v) => repo.setManualChecked(
                            listId, item.id, v ?? false),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: checked ? tokens.inkMuted : tokens.ink,
                            decoration: checked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (item.qty != null)
                        Text(
                          '${formatQty(item.qty!, locale: locale)} ${item.unit ?? ''}'.trim(),
                          style: TextStyle(
                            fontSize: 13,
                            color: checked
                                ? tokens.inkMuted.withValues(alpha: 0.5)
                                : tokens.inkMuted,
                            decoration:
                                checked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      IconButton(
                        icon: Icon(Icons.close,
                            size: 18, color: tokens.inkMuted),
                        onPressed: () =>
                            repo.removeManualItem(listId, item.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _GeneratedRowActions extends StatelessWidget {
  const _GeneratedRowActions({
    required this.item,
    required this.onEditQty,
    required this.onRemove,
    required this.onRestore,
  });

  final GeneratedItemView item;
  final ValueChanged<double> onEditQty;
  final VoidCallback onRemove;
  final VoidCallback onRestore;

  Future<void> _editQty(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final controller = TextEditingController(
      text: item.displayQty != null ? formatQty(item.displayQty!, locale: locale) : '',
    );
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.listQtyDialogTitle(_resolvedName(item, locale))),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(suffixText: item.unit),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(
                  controller.text.replaceAll(',', '.'));
              Navigator.of(ctx).pop(v);
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (value != null && value >= 0 && context.mounted) {
      onEditQty(value);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!item.isQb && !item.removed)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.listEditQty),
              onTap: () => _editQty(context),
            ),
          if (!item.removed)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l.listRemoveFromList),
              onTap: () {
                onRemove();
                Navigator.of(context).pop();
              },
            ),
          if (item.hasOverride)
            ListTile(
              leading: const Icon(Icons.restart_alt_outlined),
              title: Text(l.listRestoreCalculated),
              onTap: () {
                onRestore();
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

class _ManualDraft {
  _ManualDraft({required this.name, this.qty, this.unit});
  final String name;
  final double? qty;
  final String? unit;
}

class _ManualItemForm extends StatefulWidget {
  const _ManualItemForm();

  @override
  State<_ManualItemForm> createState() => _ManualItemFormState();
}

class _ManualItemFormState extends State<_ManualItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final qty = double.tryParse(_qtyController.text.replaceAll(',', '.'));
    final unit = _unitController.text.trim();
    Navigator.of(context).pop(_ManualDraft(
      name: _nameController.text.trim(),
      qty: qty,
      unit: unit.isEmpty ? null : unit,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.listManualTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: l.name),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                        labelText: l.listQtyLabel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: InputDecoration(
                        labelText: l.listUnitLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(l.listManualAdd)),
          ],
        ),
      ),
    );
  }
}
