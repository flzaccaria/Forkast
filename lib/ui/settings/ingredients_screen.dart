import 'package:flutter/material.dart';

import '../../core/diacritics.dart';
import '../../core/display_name.dart';
import '../../core/l10n_enums.dart';
import '../../core/reparto.dart';
import '../../core/unit.dart';
import '../../data/database.dart';
import '../../data/repositories/ingredient_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../theme.dart';
import '../widgets/forkast_app_bar.dart';
import 'ingredient_form.dart';

// ---------------------------------------------------------------------------
// Filter / sort / view enums
// ---------------------------------------------------------------------------

enum _SortField { name, department, usage }

enum _QbFilter { any, qbOnly, qtyOnly }

enum _UsageFilter { any, used, unused }

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  late final IngredientRepository _repo;

  // Search
  final _searchController = TextEditingController();
  String _query = '';

  // Filters
  final Set<String?> _filterDepartments = {}; // null = "Senza reparto"
  Unit? _filterUnit;
  _QbFilter _qbFilter = _QbFilter.any;
  _UsageFilter _usageFilter = _UsageFilter.any;

  // Sort & view
  _SortField _sortField = _SortField.name;
  bool _sortAsc = true;
  bool _grouped = true; // true = by department, false = flat

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = IngredientRepository(scope.database, scope.householdId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _filterDepartments.isNotEmpty ||
      _filterUnit != null ||
      _qbFilter != _QbFilter.any ||
      _usageFilter != _UsageFilter.any;

  void _resetFilters() {
    setState(() {
      _filterDepartments.clear();
      _filterUnit = null;
      _qbFilter = _QbFilter.any;
      _usageFilter = _UsageFilter.any;
    });
  }

  // ---------------------------------------------------------------------------
  // Filtering + sorting (in memory — fast on a few hundred entries)
  // ---------------------------------------------------------------------------

  List<IngredientWithUsage> _applySearchAndFilters(
    List<IngredientWithUsage> all,
    String locale,
  ) {
    var result = all;

    // Search: accent/case-insensitive substring on the localized display name.
    if (_query.isNotEmpty) {
      final normalizedQuery = removeDiacritics(_query).toLowerCase();
      result = result.where((item) {
        final displayName = ingredientDisplayName(item.ingredient, locale);
        final normalized = removeDiacritics(displayName).toLowerCase();
        return normalized.contains(normalizedQuery);
      }).toList();
    }

    // Filter: department
    if (_filterDepartments.isNotEmpty) {
      result = result
          .where((item) => _filterDepartments.contains(item.ingredient.category))
          .toList();
    }

    // Filter: unit
    if (_filterUnit != null) {
      result = result
          .where((item) => item.ingredient.unit == _filterUnit!.dbValue)
          .toList();
    }

    // Filter: q.b.
    if (_qbFilter == _QbFilter.qbOnly) {
      result = result.where((item) => item.ingredient.isQb).toList();
    } else if (_qbFilter == _QbFilter.qtyOnly) {
      result = result.where((item) => !item.ingredient.isQb).toList();
    }

    // Filter: usage
    if (_usageFilter == _UsageFilter.used) {
      result = result.where((item) => item.usageCount > 0).toList();
    } else if (_usageFilter == _UsageFilter.unused) {
      result = result.where((item) => item.usageCount == 0).toList();
    }

    return result;
  }

  List<IngredientWithUsage> _applySort(
    List<IngredientWithUsage> items,
    String locale,
  ) {
    final sorted = [...items];
    final dir = _sortAsc ? 1 : -1;
    switch (_sortField) {
      case _SortField.name:
        sorted.sort((a, b) {
          final na = removeDiacritics(ingredientDisplayName(a.ingredient, locale)).toLowerCase();
          final nb = removeDiacritics(ingredientDisplayName(b.ingredient, locale)).toLowerCase();
          return na.compareTo(nb) * dir;
        });
      case _SortField.department:
        sorted.sort((a, b) {
          final cmp = repartoSortIndex(a.ingredient.category)
              .compareTo(repartoSortIndex(b.ingredient.category));
          if (cmp != 0) return cmp * dir;
          final na = removeDiacritics(ingredientDisplayName(a.ingredient, locale)).toLowerCase();
          final nb = removeDiacritics(ingredientDisplayName(b.ingredient, locale)).toLowerCase();
          return na.compareTo(nb);
        });
      case _SortField.usage:
        sorted.sort((a, b) {
          final cmp = a.usageCount.compareTo(b.usageCount);
          if (cmp != 0) return cmp * dir;
          final na = removeDiacritics(ingredientDisplayName(a.ingredient, locale)).toLowerCase();
          final nb = removeDiacritics(ingredientDisplayName(b.ingredient, locale)).toLowerCase();
          return na.compareTo(nb);
        });
    }
    return sorted;
  }

  // ---------------------------------------------------------------------------
  // Grouping (reparto)
  // ---------------------------------------------------------------------------

  List<_RepartoEntry> _groupByReparto(
    List<IngredientWithUsage> items,
    String locale,
  ) {
    // Within each group, sort by name (locale-aware, accent-stripped).
    final sorted = [...items]..sort((a, b) {
        final byReparto = repartoSortIndex(a.ingredient.category)
            .compareTo(repartoSortIndex(b.ingredient.category));
        if (byReparto != 0) return byReparto;
        final na = removeDiacritics(ingredientDisplayName(a.ingredient, locale)).toLowerCase();
        final nb = removeDiacritics(ingredientDisplayName(b.ingredient, locale)).toLowerCase();
        return na.compareTo(nb);
      });
    final entries = <_RepartoEntry>[];
    String? currentLabel;
    for (final item in sorted) {
      final label = item.ingredient.category ?? repartoNonAssegnato;
      if (label != currentLabel) {
        entries.add(_RepartoHeader(label, item.ingredient.category));
        currentLabel = label;
      }
      entries.add(_RepartoItem(item));
    }
    return entries;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _addIngredient() async {
    final l = AppLocalizations.of(context);
    final created = await showIngredientForm(context, repo: _repo);
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.ingredientsAdded)),
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
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dishes = await _repo.dishesUsing(ing.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.ingredientsUsageTitle(ingredientDisplayName(ing, locale))),
        content: dishes.isEmpty
            ? Text(l.ingredientsNotUsed)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final d in dishes) Text('• $d')],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(Ingredient ing) async {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final displayName = ingredientDisplayName(ing, locale);
    final ok = await _repo.deleteIfUnused(ing.id);
    if (!ok) {
      final dishes = await _repo.dishesUsing(ing.id);
      _snack(l.ingredientsUsedInCount(displayName, dishes.length));
    } else {
      _snack(l.ingredientsDeleted(displayName));
    }
  }

  Future<void> _merge(Ingredient source) async {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final all = await _repo.watchAll().first;
    final candidates = all
        .where((i) =>
            i.id != source.id && i.unit == source.unit && i.isQb == source.isQb)
        .toList();
    if (!mounted) return;
    if (candidates.isEmpty) {
      _snack(l.ingredientsNoMergeCandidates);
      return;
    }
    final sourceName = ingredientDisplayName(source, locale);
    final target = await showDialog<Ingredient>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.ingredientsMergeTitle(sourceName)),
        children: [
          for (final c in candidates)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(c),
              child: Text(ingredientDisplayName(c, locale)),
            ),
        ],
      ),
    );
    if (target == null) return;
    final targetName = ingredientDisplayName(target, locale);
    final ok = await _repo.merge(sourceId: source.id, targetId: target.id);
    _snack(ok
        ? l.ingredientsMergeSuccess(sourceName, targetName)
        : l.ingredientsMergeError);
  }

  // ---------------------------------------------------------------------------
  // Filter bottom sheet
  // ---------------------------------------------------------------------------

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        filterDepartments: Set.of(_filterDepartments),
        filterUnit: _filterUnit,
        qbFilter: _qbFilter,
        usageFilter: _usageFilter,
        onApply: (departments, unit, qb, usage) {
          setState(() {
            _filterDepartments
              ..clear()
              ..addAll(departments);
            _filterUnit = unit;
            _qbFilter = qb;
            _usageFilter = usage;
          });
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return Scaffold(
      appBar: forkastAppBar(context),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              controller: _searchController,
              hintText: l.ingredientsSearchHint,
              leading: Icon(Icons.search, color: tokens.inkMuted),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          // Toolbar: filter + sort + view toggle
          _Toolbar(
            hasFilters: _hasFilters,
            onOpenFilters: _openFilters,
            onResetFilters: _resetFilters,
            sortField: _sortField,
            sortAsc: _sortAsc,
            grouped: _grouped,
            onSortFieldChanged: (f) => setState(() => _sortField = f),
            onSortAscToggled: () => setState(() => _sortAsc = !_sortAsc),
            onGroupedToggled: () => setState(() => _grouped = !_grouped),
          ),
          // Results
          Expanded(
            child: StreamBuilder<List<IngredientWithUsage>>(
              stream: _repo.watchAllWithUsage(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snapshot.data!;
                if (all.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.kitchen_outlined, size: 48,
                              color: tokens.inkMuted),
                          const SizedBox(height: 12),
                          Text(
                            l.ingredientsEmptyState,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: tokens.inkMuted, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final filtered = _applySearchAndFilters(all, locale);
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_outlined, size: 48,
                              color: tokens.inkMuted),
                          const SizedBox(height: 12),
                          Text(
                            l.ingredientsNoResults,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: tokens.inkMuted, fontSize: 15),
                          ),
                          if (_hasFilters) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _resetFilters,
                              icon: const Icon(Icons.filter_alt_off, size: 18),
                              label: Text(l.ingredientsFilterReset),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }
                // Result count badge
                return Column(
                  children: [
                    if (_query.isNotEmpty || _hasFilters)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l.ingredientsResultCount(filtered.length),
                            style: TextStyle(
                              fontSize: 12,
                              color: tokens.inkMuted,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: _grouped
                          ? _buildGroupedList(filtered, locale, l, tokens)
                          : _buildFlatList(filtered, locale, l, tokens),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addIngredient,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupedList(
    List<IngredientWithUsage> items,
    String locale,
    AppLocalizations l,
    ForkastTokens tokens,
  ) {
    final entries = _groupByReparto(items, locale);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        if (entry is _RepartoHeader) {
          return _StickyDepartmentHeader(
              label: entry.label, dbKey: entry.dbKey);
        }
        final item = (entry as _RepartoItem).item;
        return _IngredientTile(
          item: item,
          locale: locale,
          onTap: () => _openActions(item.ingredient),
        );
      },
    );
  }

  Widget _buildFlatList(
    List<IngredientWithUsage> items,
    String locale,
    AppLocalizations l,
    ForkastTokens tokens,
  ) {
    final sorted = _applySort(items, locale);
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => Divider(
        height: 0.5,
        indent: 20,
        endIndent: 20,
        color: tokens.border,
      ),
      itemBuilder: (context, i) {
        final item = sorted[i];
        return _IngredientTile(
          item: item,
          locale: locale,
          onTap: () => _openActions(item.ingredient),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Ingredient tile
// ---------------------------------------------------------------------------

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    required this.item,
    required this.locale,
    required this.onTap,
  });

  final IngredientWithUsage item;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ing = item.ingredient;
    final unitLabel = ing.isQb
        ? l.quantoBasta
        : Unit.tryParse(ing.unit)?.localizedLabel(l) ?? ing.unit;
    final subtitle = item.usageCount > 0
        ? '$unitLabel · ${l.ingredientsUsageCountLabel(item.usageCount)}'
        : unitLabel;
    return ListTile(
      title: Text(ingredientDisplayName(ing, locale)),
      subtitle: Text(subtitle),
      trailing: ing.isQb
          ? const Icon(Icons.all_inclusive_outlined, size: 18)
          : null,
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Toolbar
// ---------------------------------------------------------------------------

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.hasFilters,
    required this.onOpenFilters,
    required this.onResetFilters,
    required this.sortField,
    required this.sortAsc,
    required this.grouped,
    required this.onSortFieldChanged,
    required this.onSortAscToggled,
    required this.onGroupedToggled,
  });

  final bool hasFilters;
  final VoidCallback onOpenFilters;
  final VoidCallback onResetFilters;
  final _SortField sortField;
  final bool sortAsc;
  final bool grouped;
  final ValueChanged<_SortField> onSortFieldChanged;
  final VoidCallback onSortAscToggled;
  final VoidCallback onGroupedToggled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Filter button
          Badge(
            isLabelVisible: hasFilters,
            child: IconButton(
              icon: Icon(
                hasFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                size: 20,
              ),
              tooltip: l.ingredientsFilterTitle,
              onPressed: onOpenFilters,
            ),
          ),
          if (hasFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off, size: 18),
              tooltip: l.ingredientsFilterReset,
              onPressed: onResetFilters,
            ),
          const Spacer(),
          // Sort selector (only in flat mode)
          if (!grouped) ...[
            PopupMenuButton<_SortField>(
              initialValue: sortField,
              tooltip: l.ingredientsSortName,
              onSelected: onSortFieldChanged,
              icon: const Icon(Icons.sort, size: 20),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _SortField.name,
                  child: Text(l.ingredientsSortName),
                ),
                PopupMenuItem(
                  value: _SortField.department,
                  child: Text(l.ingredientsSortDepartment),
                ),
                PopupMenuItem(
                  value: _SortField.usage,
                  child: Text(l.ingredientsSortUsage),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 18,
              ),
              tooltip: sortAsc ? l.ingredientsSortAsc : l.ingredientsSortDesc,
              onPressed: onSortAscToggled,
            ),
          ],
          // View toggle
          IconButton(
            icon: Icon(
              grouped ? Icons.view_list : Icons.view_agenda_outlined,
              size: 20,
            ),
            tooltip: grouped ? l.ingredientsViewFlat : l.ingredientsViewGrouped,
            onPressed: onGroupedToggled,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bottom sheet
// ---------------------------------------------------------------------------

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.filterDepartments,
    required this.filterUnit,
    required this.qbFilter,
    required this.usageFilter,
    required this.onApply,
  });

  final Set<String?> filterDepartments;
  final Unit? filterUnit;
  final _QbFilter qbFilter;
  final _UsageFilter usageFilter;
  final void Function(Set<String?>, Unit?, _QbFilter, _UsageFilter) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final Set<String?> _departments = Set.of(widget.filterDepartments);
  late Unit? _unit = widget.filterUnit;
  late _QbFilter _qb = widget.qbFilter;
  late _UsageFilter _usage = widget.usageFilter;

  void _apply() {
    widget.onApply(_departments, _unit, _qb, _usage);
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _departments.clear();
      _unit = null;
      _qb = _QbFilter.any;
      _usage = _UsageFilter.any;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Text(l.ingredientsFilterTitle,
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(onPressed: _reset, child: Text(l.ingredientsFilterReset)),
              ],
            ),
            const SizedBox(height: 16),

            // Department multi-select
            Text(l.ingredientsFilterDepartment,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final dept in [...reparti, null])
                  FilterChip(
                    label: Text(localizedReparto(dept, l)),
                    selected: _departments.contains(dept),
                    onSelected: (sel) => setState(() {
                      if (sel) {
                        _departments.add(dept);
                      } else {
                        _departments.remove(dept);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Unit
            Text(l.ingredientsFilterUnit,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final u in Unit.values)
                  ChoiceChip(
                    label: Text(u.localizedLabel(l)),
                    selected: _unit == u,
                    onSelected: (sel) => setState(() => _unit = sel ? u : null),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Q.b.
            Text(l.ingredientsFilterQb,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l.ingredientsFilterQbYes),
                  selected: _qb == _QbFilter.qbOnly,
                  onSelected: (sel) =>
                      setState(() => _qb = sel ? _QbFilter.qbOnly : _QbFilter.any),
                ),
                ChoiceChip(
                  label: Text(l.ingredientsFilterQbNo),
                  selected: _qb == _QbFilter.qtyOnly,
                  onSelected: (sel) =>
                      setState(() => _qb = sel ? _QbFilter.qtyOnly : _QbFilter.any),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Usage
            Text(l.ingredientsFilterUsage,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l.ingredientsFilterUsed),
                  selected: _usage == _UsageFilter.used,
                  onSelected: (sel) => setState(
                      () => _usage = sel ? _UsageFilter.used : _UsageFilter.any),
                ),
                ChoiceChip(
                  label: Text(l.ingredientsFilterUnused),
                  selected: _usage == _UsageFilter.unused,
                  onSelected: (sel) => setState(
                      () => _usage = sel ? _UsageFilter.unused : _UsageFilter.any),
                ),
              ],
            ),
            const SizedBox(height: 24),

            FilledButton(onPressed: _apply, child: Text(l.confirm)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reparto header
// ---------------------------------------------------------------------------

class _StickyDepartmentHeader extends StatelessWidget {
  const _StickyDepartmentHeader({required this.label, this.dbKey});

  final String label;
  final String? dbKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final surfacePage = Theme.of(context).extension<ForkastTokens>()!.surfacePage;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      color: surfacePage,
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

// ---------------------------------------------------------------------------
// Reparto grouping entries
// ---------------------------------------------------------------------------

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
  final IngredientWithUsage item;
}

// ---------------------------------------------------------------------------
// Ingredient actions bottom sheet
// ---------------------------------------------------------------------------

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
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    void run(VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(ingredientDisplayName(ingredient, locale),
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(ingredient.isQb
                ? l.quantoBasta
                : Unit.tryParse(ingredient.unit)?.localizedLabel(l) ??
                    ingredient.unit),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(l.edit),
            onTap: () => run(onEdit),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: Text(l.ingredientsUsage),
            onTap: () => run(onShowUsage),
          ),
          ListTile(
            leading: const Icon(Icons.merge_type),
            title: Text(l.ingredientsMergeDuplicate),
            onTap: () => run(onMerge),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l.delete),
            onTap: () => run(onDelete),
          ),
        ],
      ),
    );
  }
}
