import 'package:flutter/material.dart';

import '../../core/reparto.dart';
import '../../core/week.dart';
import '../../data/database.dart';
import '../../data/repositories/list_repository.dart';
import '../../data/repositories/plan_repository.dart';
import '../app_scope.dart';
import '../widgets/settings_button.dart';

/// Lista della spesa (FR-10/11/12/13/21) per la settimana corrente. Strato
/// generato dal piano + voci manuali e spunte persistenti. La rigenerazione
/// non è automatica di default: quando il piano diverge, si mostra "Aggiorna".
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
    setState(() => _generating = true);
    try {
      await _repo.generate(weekPlanId);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista'),
        actions: const [SettingsButton()],
      ),
      body: StreamBuilder<WeekPlan?>(
        stream: _planRepo.watchWeekPlan(_year, _week),
        builder: (context, planSnap) {
          final weekPlan = planSnap.data;
          if (weekPlan == null) {
            return const _CenteredHint(
              icon: Icons.event_busy,
              text: 'Nessun piano per la settimana corrente.\n'
                  'Pianifica le cene per generare la lista.',
            );
          }
          return StreamBuilder<ShoppingList?>(
            stream: _repo.watchList(weekPlan.id),
            builder: (context, listSnap) {
              final list = listSnap.data;
              if (list == null) {
                return _EmptyList(
                  generating: _generating,
                  onGenerate: () => _generate(weekPlan.id),
                );
              }
              return _ListContent(
                repo: _repo,
                planRepo: _planRepo,
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

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.generating, required this.onGenerate});

  final bool generating;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 48),
          const SizedBox(height: 12),
          const Text('Nessuna lista per questa settimana.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: generating ? null : onGenerate,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Genera lista'),
          ),
        ],
      ),
    );
  }
}

class _ListContent extends StatefulWidget {
  const _ListContent({
    required this.repo,
    required this.planRepo,
    required this.weekPlanId,
    required this.list,
    required this.generating,
    required this.onRegenerate,
  });

  final ListRepository repo;
  final PlanRepository planRepo;
  final String weekPlanId;
  final ShoppingList list;
  final bool generating;
  final VoidCallback onRegenerate;

  @override
  State<_ListContent> createState() => _ListContentState();
}

class _ListContentState extends State<_ListContent> {
  bool _diverged = false;

  @override
  void initState() {
    super.initState();
    _checkDivergence();
  }

  @override
  void didUpdateWidget(_ListContent old) {
    super.didUpdateWidget(old);
    if (old.list.planHash != widget.list.planHash) {
      _checkDivergence();
    }
  }

  Future<void> _checkDivergence() async {
    final current = await widget.repo.currentPlanHash(widget.weekPlanId);
    final diverged = current != widget.list.planHash;
    // Rigenerazione automatica opzionale (FR-21).
    if (diverged && await widget.repo.autoRegen()) {
      widget.onRegenerate();
      return;
    }
    if (mounted) setState(() => _diverged = diverged);
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
    return Scaffold(
      body: Column(
        children: [
          if (_diverged)
            MaterialBanner(
              backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer,
              content: const Text('Il piano è cambiato dopo la generazione.'),
              leading: const Icon(Icons.info_outline),
              actions: [
                TextButton(
                  onPressed: widget.generating ? null : widget.onRegenerate,
                  child: const Text('Aggiorna'),
                ),
              ],
            ),
          Expanded(
            child: CustomScrollView(
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addManual,
        icon: const Icon(Icons.add),
        label: const Text('Voce manuale'),
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

  String _qtyLabel(GeneratedItemView item) {
    if (item.isQb) return 'q.b.';
    final qty = item.displayQty;
    if (qty == null) return '';
    final n = qty == qty.roundToDouble()
        ? qty.toInt().toString()
        : qty.toString();
    return '$n ${item.unit}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GeneratedItemView>>(
      stream: repo.watchGeneratedItems(listId),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Lo strato generato è vuoto: il piano di questa settimana '
                'non ha piatti con ingredienti.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        // Raggruppa per reparto seguendo l'ordine del percorso in negozio
        // (lista fissa in core/reparto.dart); gli ingredienti senza reparto
        // finiscono in coda. Dentro ogni reparto resta l'ordine per nome
        // garantito dalla query.
        final entries = _groupByReparto(items);
        return SliverList.builder(
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final entry = entries[i];
            if (entry is _RepartoHeader) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  entry.label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                ),
              );
            }
            final item = (entry as _RepartoItem).item;
            final textStyle = item.removed
                ? const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  )
                : null;
            return ListTile(
              leading: Checkbox(
                value: item.checked,
                onChanged: item.removed
                    ? null
                    : (v) => repo.setIngredientChecked(
                        listId, item.ingredientId, v ?? false),
              ),
              title: Text(item.name, style: textStyle),
              subtitle: item.hasOverride && !item.removed
                  ? const Text('modificato')
                  : (item.removed ? const Text('rimosso') : null),
              trailing: Text(_qtyLabel(item), style: textStyle),
              onTap: () => onTapRow(item),
            );
          },
        );
      },
    );
  }

  /// Trasforma la lista piatta in una sequenza di intestazioni di reparto +
  /// righe, ordinata per percorso in negozio.
  List<_RepartoEntry> _groupByReparto(List<GeneratedItemView> items) {
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
}

sealed class _RepartoEntry {
  const _RepartoEntry();
}

class _RepartoHeader extends _RepartoEntry {
  const _RepartoHeader(this.label);
  final String label;
}

class _RepartoItem extends _RepartoEntry {
  const _RepartoItem(this.item);
  final GeneratedItemView item;
}

class _ManualSection extends StatelessWidget {
  const _ManualSection({required this.repo, required this.listId});

  final ListRepository repo;
  final String listId;

  String _qtyLabel(ManualItemView item) {
    if (item.qty == null) return '';
    final q = item.qty!;
    final n = q == q.roundToDouble() ? q.toInt().toString() : q.toString();
    return '$n ${item.unit ?? ''}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ManualItemView>>(
      stream: repo.watchManualItems(listId),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const [];
        if (items.isEmpty) return const SliverToBoxAdapter();
        return SliverMainAxisGroup(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Aggiunte manuali',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = items[i];
                return ListTile(
                  leading: Checkbox(
                    value: item.checked,
                    onChanged: (v) =>
                        repo.setManualChecked(listId, item.id, v ?? false),
                  ),
                  title: Text(item.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_qtyLabel(item)),
                      IconButton(
                        icon: const Icon(Icons.close),
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
    final controller = TextEditingController(
      text: item.displayQty?.toString() ?? '',
    );
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quantità — ${item.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(suffixText: item.unit),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(
                  controller.text.replaceAll(',', '.'));
              Navigator.of(ctx).pop(v);
            },
            child: const Text('Salva'),
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
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!item.isQb && !item.removed)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifica quantità'),
              onTap: () => _editQty(context),
            ),
          if (!item.removed)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Rimuovi dalla lista'),
              onTap: () {
                onRemove();
                Navigator.of(context).pop();
              },
            ),
          if (item.hasOverride)
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Ripristina valore calcolato'),
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Voce manuale',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Quantità (opzionale)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                        labelText: 'Unità (opz.)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Aggiungi')),
          ],
        ),
      ),
    );
  }
}

class _CenteredHint extends StatelessWidget {
  const _CenteredHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(text, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
